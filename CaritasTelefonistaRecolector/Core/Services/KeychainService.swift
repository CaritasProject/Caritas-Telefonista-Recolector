import Foundation
import Security

class KeychainService {
    func save(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }

        let queryDelete: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(queryDelete as CFDictionary)

        let queryAdd: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemAdd(queryAdd as CFDictionary, nil)
    }

    func read(for key: String) -> String? {
        let queryRead: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var resultado: AnyObject?
        let estado = SecItemCopyMatching(queryRead as CFDictionary, &resultado)

        if estado == errSecSuccess, let data = resultado as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    func delete(for key: String) {
        let queryDelete: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(queryDelete as CFDictionary)
    }
}
