package ;

import formatter.Formatter;
import formatter.config.Config;
import js.html.SelectElement;
import js.html.TextAreaElement;
import tokentree.TokenTreeBuilder.TokenTreeEntryPoint;

import coconut.Ui.hxx;
import coconut.ui.View;
import js.Browser.document;

/**
	@author Mark Knol
**/
class Main {
	public static function main() {
		coconut.ui.Renderer.mount(cast document.body.appendChild(document.createElement("main")), hxx('<Root />'));
	}
}

class Root extends View {
	@:state var codeString:String = "class Main\n{\n\n\n\n}";
	@:state var configString:String = "{}";

	@:const var entryPoints = TokenTreeEntryPoint.createAll();
	@:state var entryPoint:TokenTreeEntryPoint = TokenTreeEntryPoint.TYPE_LEVEL;
	
	var _config:Config = new Config();
	@:computed var config:Config = { _config.readConfigFromString(configString, "unknown"); _config; }
	@:computed var formatterResult:Result = Formatter.format(Code(codeString), config, null, entryPoint);

	var _formattedCode:String;
	@:computed var formattedCode:String = switch formatterResult {
		case Success(code): _formattedCode = code;
		case Failure(_) | Disabled: _formattedCode;
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
				<textarea oninput=${codeString = (cast event.target:TextAreaElement).value}>$codeString</textarea>
			</section>
			<section class="well">
				Formatted code:
				<textarea disabled>$formattedCode</textarea>
			</section>
			<section class="well active">
				hxformat.json configuration file:
				<textarea oninput=${configString = (cast event.target:TextAreaElement).value}>$configString</textarea>
			</section>
			<footer class="status">
				<strong>Mode</strong> ${Std.string(entryPoint)} | 
				<strong>Status</strong>
				<switch ${formatterResult}>
					<case ${Success(code)}> <span class="label-success">Valid!</span>
					<case ${Failure(error)}> <span class="label-error">${error}</span>
					<case ${Disabled}> <span class="label-disabled">Disabled</span>
				</switch>
			</footer>
		</div>;
}
