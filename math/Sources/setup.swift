import Foundation

// Setup function to prepare Mathison's environment
func setup(scriptManager: ScriptManager) -> (String?, Bool) {
    print("Setting up Mathison...")

    // Step 1: Load all scripts from the Resources folder
    print("Loading scripts...")
    scriptManager.loadScripts(from: "./Resources")

    // Step 2: Check for existing user memory or initialize a new one
    print("Initializing user memory...")
    let memoryDirectory = "./memories"

    // Check for existing user memory files
    let existingFiles = try? FileManager.default.contentsOfDirectory(atPath: memoryDirectory)
    let userName: String?
    let isNewUser: Bool

    if let files = existingFiles, !files.isEmpty {
        // Assuming the files are named <username>.json
        userName = files.first?.replacingOccurrences(of: ".json", with: "")
        print("Welcome back, \(userName!)!")
        isNewUser = false
    } else {
        print("Welcome, new user! Please enter your name:")
        if let newUserName = readLine() {
            let fileName = "\(newUserName).json"  // Create filename based on user name
            let newFilePath = "\(memoryDirectory)/\(fileName)"
            
            // Create a new user memory file
            FileManager.default.createFile(atPath: newFilePath, contents: nil, attributes: nil)
            print("New user memory created for \(newUserName).")
            userName = newUserName
            isNewUser = true
        } else {
            userName = nil
            isNewUser = true
        }
    }

    // Set up the conversation context
    scriptManager.currentScript = "intro.json"
    print("Setup complete. Ready to begin!")

    return (userName, isNewUser)
}
