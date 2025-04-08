package edge.access

default allow = false

allow {
    input.user == "edge_admin"
}