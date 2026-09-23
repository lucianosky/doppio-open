// APIResponse.swift
// Brew/Shared
//
// Generic wrapper for the standard API response envelope: { "data": ... }
//
// Most endpoints wrap their payload in a top-level "data" key.
// The two exceptions are POST /auth/register and POST /auth/login,
// which return the auth payload at the root level without the "data" key.
// Those endpoints are decoded directly by RemoteDataSource without this wrapper.

/// Decodes the standard `{ "data": T }` API response envelope.
///
/// Used internally by `RemoteDataSource` to unwrap responses before
/// passing the decoded value up to the Repository layer.
///
/// Example API response:
/// ```json
/// {
///   "data": {
///     "available_credits": 10,
///     "allow_new_consumption": true
///   }
/// }
/// ```
///
/// Usage:
/// ```swift
/// let envelope = try decoder.decode(APIResponse<Wallet>.self, from: data)
/// return envelope.data
/// ```
public struct APIResponse<T: Decodable>: Decodable {

    /// The unwrapped payload from the `"data"` key.
    public let data: T
}
