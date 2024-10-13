import Foundation

let scriptManager = ScriptManager()

@MainActor
func main() {
    // Call setup to initialize everything
    let (userName, isNewUser) = setup(scriptManager: scriptManager)
    
    // Now you can start the conversation
    scriptManager.runIntro(for: userName, isNewUser: isNewUser)
}

main()
