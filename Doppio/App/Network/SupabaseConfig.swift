// SupabaseConfig.swift
// App/Network
//
// Fill in your Supabase project credentials before building.
// Find these values in your Supabase project settings → API.

import Foundation

// MARK: - SupabaseConfig

enum SupabaseConfig {

    /// Base URL of the Supabase project (no trailing slash).
    static let projectURL = "YOUR_SUPABASE_PROJECT_URL"

    /// PostgREST REST API base URL.
    static let restURL = projectURL + "/rest/v1"

    /// Anon (publishable) key — find it in Supabase → Settings → API.
    static let anonKey = "YOUR_SUPABASE_ANON_KEY"
}
