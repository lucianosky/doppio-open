// URLError+Doppio.swift
// App/Extensions
//
// Maps common URLError codes to user-friendly Portuguese messages.

import Foundation

extension Error {
    /// Returns a user-friendly Portuguese message for network errors.
    var doppioMessage: String {
        if let urlError = self as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "Sem conexão com a internet. Verifique sua rede e tente novamente."
            case .timedOut:
                return "A requisição demorou muito. Tente novamente."
            case .cannotFindHost, .cannotConnectToHost:
                return "Não foi possível conectar ao servidor. Tente novamente mais tarde."
            default:
                break
            }
        }
        if let repoError = self as? RepositoryError {
            switch repoError {
            case .network(let statusCode, _) where statusCode >= 500:
                return "O servidor está com problemas. Tente novamente mais tarde."
            case .network(_, let message):
                return message
            case .unauthorized:
                return "Sessão expirada. Faça login novamente."
            case .notFound:
                return "Conteúdo não encontrado."
            default:
                break
            }
        }
        return "Não foi possível carregar. Tente novamente."
    }
}
