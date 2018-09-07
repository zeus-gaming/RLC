function onScriptLoad() {
	dofile( "rlc.nut", true );
	rlc_table.onScriptLoad( );
}

function onPlayerJoin( player ) {
	rlc_table.onPlayerJoin( player );
}

function onPlayerPart( player, reason ) {
	rlc_table.onPlayerPart( player );
}

function onPlayerCommand( player, command, arguments ) {
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
}