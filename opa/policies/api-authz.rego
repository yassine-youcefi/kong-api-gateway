package kong.authz

default allow = false

# Allow /user/details/ only for agent and agency roles
allow if {
    input.request.path == "/user/details/"
    some role in input.parsed_jwt.payload.roles
    role in {"agent", "agency"}
}
