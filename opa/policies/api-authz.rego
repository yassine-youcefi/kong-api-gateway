package kong.authz

default allow = false

# Allow /user/details/ only for agent and agency roles
allow {
    input.request.path == "/user/details/"
    some role
    input.parsed_jwt.payload.roles[_] == role
    role == "agent" or role == "agency"
}
