package kong.authz

default allow = false

# Example: allow if JWT contains a role of "agent" or "agency"
allow {
    some role
    input.parsed_jwt.payload.roles[_] == role
    role == "agent"
}
allow {
    some role
    input.parsed_jwt.payload.roles[_] == role
    role == "agency"
}
