"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deactivate = exports.activate = void 0;
// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
const vscode = require("vscode");
// this method is called when your extension is activated
// your extension is activated the very first time the command is executed
function activate(context) {
    // The command has been defined in the package.json file
    // Now provide the implementation of the command with registerCommand
    // The commandId parameter must match the command field in package.json
    let disposable = vscode.commands.registerCommand('bootstrap5-vscode.openCyberDudeChannel', () => {
        vscode.env.openExternal(vscode.Uri.parse("https://www.youtube.com/results?search_query=cyberdude"));
        vscode.window.showInformationMessage('That\'s great! Opening CyberDude YT Channel. ❤️ 😊', 'Github', 'Website').then(selection => {
            switch (selection) {
                case "Github":
                    vscode.env.openExternal(vscode.Uri.parse("https://www.github.com/anburocky3"));
                    break;
                case "Website":
                    vscode.env.openExternal(vscode.Uri.parse("https://www.cyberdudenetworks.com"));
                    break;
            }
        });
    });
    context.subscriptions.push(disposable);
}
exports.activate = activate;
// this method is called when your extension is deactivated
function deactivate() { }
exports.deactivate = deactivate;
//# sourceMappingURL=extension.js.map