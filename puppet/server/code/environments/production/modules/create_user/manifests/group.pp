class create_user::group {
  group { 'common':
    ensure   => 'present',
    gid      => 2000,
  }
}
