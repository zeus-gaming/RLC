# RLC Register Login &amp; Change Password
  A basic rlc system for Vice City Multiplayer.

##### > Available Commands
```js
     -> /commands
     -> /register <password>
     -> /login <password>
     -> /changepass <old-password> <new-password>
```

##### > Plugins Required
```js
     -> Squirrel
     -> Sqlite
     -> Hashing
```

##### > Installation
place `rlc.nut` inside `svr_directory`.
open `main.nut` file and add the bellow stuff to their required event.
  ```js
/* onScriptLoad() */
dofile( "rlc.nut", true );
rlc_table.onScriptLoad( );
```
  ```js
/* onPlayerJoin( player ) */
rlc_table.onPlayerJoin( player );
```
  ```js
/* onPlayerPart( player, reason ) */
rlc_table.onPlayerPart( player );
```
  ```js
/* onPlayerCommand( player, command, arguments ) */
switch( command ) {
   case "register":
   case "login":
   case "changepass":
      rlc_table.onPlayerCommand( player, command, arguments );
   break;
   case "commands":
      MessagePlayer( "[#7bb215][RLC] [#15a26f]RLC Commands: [/] register, login, changepass.", player );
   break;
   default:
      MessagePlayer( "[#7bb215][RLC] [#cc3510](ERROR) Invalid command, use /commands to check for availble commands.", player );
}
```

##### > VCMP Topic
[[RLC] Regiister Login & Change Password](https://forum.vc-mp.org/?topic=5144.msg37031#msg37031 "RLC")
