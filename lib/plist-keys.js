// Top-level key operations on a property list file, for the settings apps.
// Uses Foundation through JXA, so keys containing dots or colons work and
// every plist type (data, date, dict, array) round-trips.
//
//   osascript -l JavaScript plist-keys.js filter <in> <out> <glob>...
//       Keep the top-level keys matching any glob; write <out> as XML.
//       Prints the number of keys kept.
//   osascript -l JavaScript plist-keys.js fragments <in>
//       Print "<key>\0<value as an XML plist fragment>\0" for every key,
//       ready for `defaults write <domain> <key> <fragment>`.
//   osascript -l JavaScript plist-keys.js diff <before> <after>
//       Print the keys that were added, removed or changed.
ObjC.import("Foundation");

function read(path) {
  const dict = $.NSDictionary.dictionaryWithContentsOfFile(path);
  if (dict.isNil()) {
    throw new Error("not a property list: " + path);
  }
  return dict;
}

function keys(dict) {
  return ObjC.deepUnwrap(dict.allKeys).sort();
}

function globToRegExp(glob) {
  const escaped = glob.replace(/[.+^${}()|[\]\\]/g, "\\$&");
  return new RegExp("^" + escaped.replace(/\*/g, ".*").replace(/\?/g, ".") + "$");
}

function fragment(value) {
  const data = $.NSPropertyListSerialization.dataWithPropertyListFormatOptionsError(
    value,
    $.NSPropertyListXMLFormat_v1_0,
    0,
    null,
  );
  const xml = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js;
  return xml
    .split("\n")
    .filter((line) => !/^(<\?xml|<!DOCTYPE|<plist|<\/plist>)/.test(line))
    .join("\n")
    .trim();
}

function write(text) {
  const data = $(text).dataUsingEncoding($.NSUTF8StringEncoding);
  $.NSFileHandle.fileHandleWithStandardOutput.writeData(data);
}

function run(argv) {
  const [command, ...args] = argv;
  if (command === "filter") {
    const [input, output, ...globs] = args;
    const dict = read(input);
    const patterns = globs.map(globToRegExp);
    const kept = $.NSMutableDictionary.dictionary;
    for (const key of keys(dict)) {
      if (patterns.some((pattern) => pattern.test(key))) {
        kept.setObjectForKey(dict.objectForKey(key), key);
      }
    }
    if (!kept.writeToFileAtomically(output, true)) {
      throw new Error("could not write " + output);
    }
    return String(kept.count);
  }
  if (command === "fragments") {
    const dict = read(args[0]);
    for (const key of keys(dict)) {
      write(key + "\0" + fragment(dict.objectForKey(key)) + "\0");
    }
    return;
  }
  if (command === "diff") {
    const before = read(args[0]);
    const after = read(args[1]);
    const all = [...new Set([...keys(before), ...keys(after)])].sort();
    const lines = [];
    for (const key of all) {
      const old = before.objectForKey(key);
      const now = after.objectForKey(key);
      if (old.isNil()) lines.push("+ " + key + " = " + fragment(now));
      else if (now.isNil()) lines.push("- " + key);
      else if (!old.isEqual(now)) lines.push("~ " + key + " = " + fragment(now));
    }
    return lines.join("\n");
  }
  throw new Error("usage: plist-keys.js filter|fragments|diff ...");
}
