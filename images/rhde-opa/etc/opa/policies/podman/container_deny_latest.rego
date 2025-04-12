package podman.policy

# Deny containers using "latest" tag
deny[msg] {
    container := input.containers[_]
    image := container.Image
    endswith(image, ":latest")  # explicitly tagged as latest
    msg := sprintf("Container '%s' uses 'latest' tag in image '%s'", [container.Name, image])
}

# Also catch implicit latest (no tag at all)
deny[msg] {
    container := input.containers[_]
    not contains(container.Image, ":")  # no tag specified at all
    msg := sprintf("Container '%s' uses an image '%s' with no explicit tag (defaults to 'latest')", [container.Name, container.Image])
}
