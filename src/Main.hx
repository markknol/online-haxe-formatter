package ;

import formatter.Formatter;
import formatter.config.Config;
import js.Browser;
import js.html.SelectElement;
import js.html.TextAreaElement;
import tokentree.TokenTreeBuilder.TokenTreeEntryPoint;

import coconut.Ui.hxx;
import coconut.ui.View;
import js.Browser.document;
import lzstring.LZString;

/**
	@author Mark Knol
**/
class Main {
	public static function main() {
		coconut.ui.Renderer.mount(cast document.body.appendChild(document.createElement("main")), hxx('<Root  />'));
	}
}

class Root extends View {
	@:const var formatterVersion:String = haxe.macro.Compiler.getDefine("formatter");
	@:const var entryPoints = TokenTreeEntryPoint.createAll();
	
	@:state var codeString:String = getFromStorage('code', "class Main\n{\n\n\n\n}");
	@:state var configString:String = getFromStorage('config', "{}");
	
	@:state var configIsValid:Bool = true;
	@:state var entryPoint:TokenTreeEntryPoint = TokenTreeEntryPoint.TYPE_LEVEL;
	
	var _encoder = new LZString();
	inline function getFromStorage(key:String, fallback:String):String {
		var hash = js.Browser.location.hash;
		trace(hash.substr(1));
		if (hash.length>1) {
			var data:haxe.DynamicAccess<String> = haxe.Json.parse(_encoder.decompressFromEncodedURIComponent(hash.substr(1)));
			return data.get(key);
		}
		return fallback;
	}
	
	var _config:Config = new Config();
	@:skipCheck @:computed var config:Config = {
		try {
			configIsValid = true;
			_config.readConfigFromString(configString, "unknown");
		} catch (e:Any) {
			configIsValid = false;
		}
		_config;
	}
	@:computed var formatterResult:Result = Formatter.format(Code(codeString), config, null, entryPoint);

	var _formattedCode:String;
	@:computed var formattedCode:String = switch formatterResult {
		case Success(code): _formattedCode = code;
		case Failure(_) | Disabled: _formattedCode;
	}
	
	function store(value) {
		js.Browser.location.hash = _encoder.compressToEncodedURIComponent(haxe.Json.stringify({code:codeString, config:configString }));
		return value;
	}
	
	function render()
		<div>
			<select onchange=${entryPoint = entryPoints[(cast event.target:SelectElement).selectedIndex]}>
				<for {p in entryPoints}>
					<option selected=${entryPoint == p}>${Std.string(p)}</option>
				</for>
			</select>
			<section class="well active">
				Input code:
				<textarea oninput=${codeString = store((cast event.target:TextAreaElement).value)}>$codeString</textarea>
			</section>
			<section class="well">
				Formatted code:
				<textarea disabled>$formattedCode</textarea>
			</section>
			<section class="well active">
				hxformat.json configuration file:
				<textarea oninput=${configString = store((cast event.target:TextAreaElement).value)}>$configString</textarea>
			</section>
			<footer class="status">
				<if {!configIsValid}> <span class="label-error">Broken hxformat.json</span> <span class='pipe'>|</span> </if>
				<switch ${formatterResult}>
					<case ${Success(code)}> <strong>Mode</strong>${Std.string(entryPoint)} <span class='pipe'>|</span> haxe-formatter ${formatterVersion}
					<case ${Failure(error)}> <span class="label-error">${error} </span>
					<case ${Disabled}> <span class="label-disabled">Disabled</span>
				</switch>
			</footer>
		</div>;
}


