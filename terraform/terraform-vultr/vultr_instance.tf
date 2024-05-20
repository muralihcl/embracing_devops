resource "vultr_instance" "devops_instance" {
    label = "tf-server"
    plan = "vc2-1c-1gb"
    region = "blr"
    os_id = "387"
    enable_ipv6 = true
}
