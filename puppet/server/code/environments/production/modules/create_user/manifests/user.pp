class create_user::user {
  user { 'user1':
    ensure   => 'present',
    uid      => 1001,
    gid      => 2000,
    comment  => 'User created via puppet',
    managehome => true,
    password => '$6$Evh28Mbh0keN2PrV$NVTekw2YU7dgKsUYi6XwnORRg/09iZMvh4A3bnpVsiQ8BSBQZeST7bvDqGiperx.CsezvadJpBjFMO4F1USZu1'
  }
  
  user { 'user2':
    ensure   => 'present',
    uid      => 1002,
    gid      => 2000,
    comment  => 'User created via puppet',
    managehome => true,
    password => '$6$Evh28Mbh0keN2PrV$NVTekw2YU7dgKsUYi6XwnORRg/09iZMvh4A3bnpVsiQ8BSBQZeST7bvDqGiperx.CsezvadJpBjFMO4F1USZu1'
  }
}
