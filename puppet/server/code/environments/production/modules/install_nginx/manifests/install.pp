class install_nginx::install {
  package { 'nginx':
    ensure   => 'present'
  }
}
