import Foundation

class MemoryFileManager {
    let memoryDirectory = "./memories"
    
    // Function to load or initialize user memory
    func loadUserMemory() -> String? {
        ensureMemoryDirectoryExists()
        print("Enter your name: ")
        
        if let userName = readLine() {
            if let fileName = findUserFileName(userName: userName) {
                // Load user memory from their file
                let userFilePath = "\(memoryDirectory)/\(fileName)"
                return loadUserMemory(from: userFilePath)
            } else {
                // New user, create new memory file
                print("User not found. Creating new memory for \(userName).")
                let randomFileName = generateAlphanumericFileName()
                createNewUserMemory(userName: userName, fileName: randomFileName)
                return userName
            }
        }
        
        return nil
    }

    // Find the user's file by checking each file in the memory directory
    private func findUserFileName(userName: String) -> String? {
        do {
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(atPath: memoryDirectory)
            
            for file in files where file.hasSuffix(".json") {
                let filePath = "\(memoryDirectory)/\(file)"
                if let memoryData = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
                   let userMemory = try? JSONSerialization.jsonObject(with: memoryData, options: []) as? [String: String],
                   userMemory["name"] == userName {
                    return file  // Found the correct file
                }
            }
        } catch {
            print("Error finding user file: \(error)")
        }
        return nil
    }

    // Generate a 32-digit alphanumeric file name
    private func generateAlphanumericFileName() -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString = (0..<32).map { _ in characters.randomElement()! }
        return String(randomString) + ".json"
    }

    // Load existing user memory from their file
    private func loadUserMemory(from filePath: String) -> String? {
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                let memoryData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                if let userMemory = try JSONSerialization.jsonObject(with: memoryData, options: []) as? [String: String] {
                    print("Welcome back, \(userMemory["name"] ?? "User")!")
                    return userMemory["name"]
                }
            } catch {
                print("Error loading user memory: \(error)")
            }
        }
        return nil
    }

    // Create a new user memory file
    private func createNewUserMemory(userName: String, fileName: String) {
        let userFilePath = "\(memoryDirectory)/\(fileName)"
        let userMemory: [String: String] = ["name": userName]

        do {
            let memoryData = try JSONSerialization.data(withJSONObject: userMemory, options: [])
            try memoryData.write(to: URL(fileURLWithPath: userFilePath))
            print("New user memory created for \(userName).")
        } catch {
            print("Error creating user memory: \(error)")
        }
    }

    // Ensure the memories directory exists
    func ensureMemoryDirectoryExists() {
        if !FileManager.default.fileExists(atPath: memoryDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: memoryDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Memory directory created.")
            } catch {
                print("Error creating memory directory: \(error)")
            }
        }
    }
}
