package;

using StringTools;

/**
 * @author Mark Knol
 */
class Macro {
	public static macro function getVersion() {
		var version = sys.io.File.getContent("haxe_libraries/formatter.hxml").split("\n")[0].replace("-D formatter=", "");
		return macro $v{version};
	}
}