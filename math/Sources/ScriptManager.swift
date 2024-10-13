import Foundation

class ScriptManager {
    private(set) var scripts: [String: [String: Any]] = [:]  // Dictionary to store loaded scripts
    var currentScript: String = "intro.json"                 // Current script to run

    // Function to load all scripts from the Resources directory
    func loadScripts(from directory: String) {
        let fileManager = FileManager.default
        if let enumerator = fileManager.enumerator(atPath: directory) {
            for case let file as String in enumerator where file.hasSuffix(".json") {
                if let script = loadScript(named: file, from: directory) {
                    scripts[file] = script
                }
            }
        }
    }

    // Load a specific script from the Resources folder
    private func loadScript(named fileName: String, from directory: String) -> [String: Any]? {
        let filePath = "\(directory)/\(fileName)"
        
        do {
            let fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
            if let jsonData = fileContent.data(using: .utf8) {
                let scriptData = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                return scriptData
            }
        } catch {
            print("Failed to load script: \(fileName). Error: \(error)")
        }
        return nil
    }

    // Run the intro script with all elements included
    func runIntro(for userName: String?, isNewUser: Bool) {
        // Load the intro script from the loaded scripts dictionary
        if let introScript = scripts["intro.json"]?["intro"] as? [String: String] {
            
            if isNewUser {
                if let greeting = introScript["greeting"] {
                    print(greeting)
                }
            } else {
                if let memoryLoading = introScript["memory_loading"], let nameRecognition = introScript["name_recognition"], let userName = userName {
                    print("\(memoryLoading)")
                    print(nameRecognition.replacingOccurrences(of: "{name}", with: userName))
                }
            }

            // Ask the leading question from the intro script
            if let leadingQuestion = introScript["leading_question"] {
                print(leadingQuestion)
                if let userInput = readLine() {
                    let keywords = userInput.lowercased().split(separator: " ").map { String($0) }
                    currentScript = decideNextScript(for: keywords)
                    runCurrentScript()
                }
            }
        } else {
            print("Intro script not found.")
        }
    }

    // Decide which script to load next based on keywords
    func decideNextScript(for keywords: [String]) -> String {
        if keywords.contains("relationship") {
            return "relationships.json"
        } else if keywords.contains("emotion") || keywords.contains("stressed") {
            return "emotions.json"
        } else if keywords.contains("study") || keywords.contains("exams") {
            return "study_exams.json"
        } else {
            return "general_conversation.json"  // Default script
        }
    }

    // Run the current script
    func runCurrentScript() {
        // Check if the script exists and print the name
        if scripts[currentScript] != nil {
            print("Running script: \(currentScript)")
        } else {
            print("Script not found: \(currentScript)")
        }
    }
}
