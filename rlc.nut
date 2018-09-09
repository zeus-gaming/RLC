RLC <- array( GetMaxPlayers(), null );
dbRLC <- null

rlc_table <- {
  databaseName = "RLC.db",
  
  /* private Functions( accessed within table ) */
  function databaseConnection() {
    ::dbRLC = ::ConnectSQL( databaseName );
    ::print( "[RLC] (SQLite) connection has been made with "+databaseName );
  }
  function databaseTables() {
    ::QuerySQL( dbRLC, "CREATE TABLE IF NOT EXISTS rlc_accounts ( p_unique_id Integer PRIMARY KEY AUTOINCREMENT, p_name VARCHAR(25), p_password VARCHAR(255), p_ip VARCHAR(20), p_uid VARCHAR(20), p_uid2 VARCHAR(20), p_level NUMERIC DEFAULT 1, p_date_registered TEXT )" );
    ::print( "[RLC] (SQLite) tables are created successfully." );
  }
  
  /* public Functions( accessed from outside table ) */
  function onScriptLoad() {
    databaseConnection( );
    databaseTables( );
  }
  
  function onPlayerJoin( player ) {
    if ( RLC[ player.ID ] != null ) RLC[ player.ID ] = null;
    RLC[ player.ID ] = rlc_class( player );
  }
  
  function onPlayerPart( player ) {
    RLC[ player.ID ].Update( );
    if ( RLC[ player.ID ] != null ) RLC[ player.ID ] = null;
  }
  
  function onPlayerCommand( player, command, arguments ) {
    switch( command ) {
      case "register":
        RLC[ player.ID ].Register( arguments );
      break;
      case "login":
        RLC[ player.ID ].Login( arguments );
      break;
      case "changepass":
        RLC[ player.ID ].ChangePassword( arguments );
      break;
    }
  }
  
  function getAccountID( arg ) {
    if ( typeof(arg) == "Instance" ) arg = arg.Name;
    
    local query = ::QuerySQL( dbRLC, "SELECT p_unique_id FROM rlc_accounts WHERE p_name LIKE '"+arg+"'" );
    if ( query ) {
      local accID = ::GetSQLColumnData( query, 0 );
      ::FreeSQLQuery( query );
      return accID;
    }
    return;
  }
};

class rlc_class {
  Player   =	null;
  accID    =	null;
  accPass  =	null;
  Reg      =	false;
  Log      =	false;
  
  constructor( player ) {
    local query = ::QuerySQL( dbRLC, "SELECT p_unique_id, p_password, p_uid2 FROM rlc_accounts WHERE p_name LIKE '"+player.Name+"'" );
    if ( query ) {
      if ( ::GetSQLColumnData( query, 2 ) == player.UID2 ) {
        this.Reg = true;
        this.Log = true;
        this.accID = ::GetSQLColumnData( query, 0 );
        this.accPass = ::GetSQLColumnData( query, 1 );
        this.Player = player;
        ::FreeSQLQuery( query );
        ::MessagePlayer( "[#7bb215] [RLC] [#11c6bd]Welcome back "+player.Name+", you have auto logged in.", player );
      }
      else {
        this.Reg = true;
        this.Log = false;
        this.accID = ::GetSQLColumnData( query, 0 );
        this.accPass = ::GetSQLColumnData( query, 1 );
        this.Player = player;
        ::FreeSQLQuery( query );
        ::MessagePlayer( "[#7bb215][RLC] [#11c6bd]Welcome back "+player.Name+" this is a registered account, /login to access server features.", player );
      }
    }
    else {
      this.Reg = false;
      this.Log = false;
      this.accID = null;
      this.Player = player;
      ::MessagePlayer( "[#7bb215][RLC] [#11c6bd]Welcome "+player.Name+", /register to access all server features.", player );
    }
  }
    
  function Update() {
    if ( this.Log ) {
      ::QuerySQL( dbRLC, "UPDATE rlc_accounts SET p_ip='"this.Player.IP"', p_uid='"this.Player.UID"', p_uid2='"this.Player.UID2"'  WHERE p_unique_id LIKE '"+this.accID+"'" );
    }
  }
  
  function Register( password ) {
    if ( this.Reg ) return ::MessagePlayer( "[#7bb215][RLC] [#cc3510](ERROR) This account is already registered.", this.Player );
    if ( !password ) return ::MessagePlayer( "[#7bb215][RLC] [#cc3510](ERROR) Usage: /register <pssword>.", this.Player );
    
    local hPassword = ::SHA256( split( password, " " )[0] );
    ::QuerySQL( dbRLC, "INSERT INTO rlc_accounts( 'p_name', 'p_password', 'p_ip', 'p_uid', 'p_uid2', 'p_date_registered' ) VALUES( '"+this.Player.Name+"', '"+hPassword+"', '"+this.Player.IP+"', '"+this.Player.UID+"', '"+this.Player.UID2+"',  '"+date().day.tostring()+"/"+date().month.tostring()+"/"+date().year.tostring()+"' )" );
    this.Reg = true;
    this.Log = true;
    this.accID = rlc_table.getAccountID( this.Player.Name );
    ::MessagePlayer( "[#7bb215][RLC] [#11c6bd]This account has been registered with password "+::split( password, " " )[0]+", don't forget the password.", this.Player );
  }
  
  function Login( password ) {
    if ( !this.Reg ) return ::MessagePlayer( "[#7bb215][RLC] [#cc3510](ERROR) This account is not registered yet, use /register to register this account.", this.Player );
    if ( this.Log ) return ::MessagePlayer( "[#7bb215][RLC] [#cc3510](ERROR) You are already logged in.", this.Player );
    if ( !password ) return ::MessagePlayer( "[#7bb215][RLC] [#cc3510](ERROR) Usage: /login <pssword>.", this.Player );
  
    local hPassword = ::SHA256( split( password, " " )[0] );
    if ( hPassword != this.accPass ) return ::MessagePlayer( "[#7bb215][RLC] [#cc3510](ERROR) Incorrect password.", this.Player );
  
    this.Log = true;
    ::MessagePlayer( "[#7bb215][RLC] [#11c6bd]You have logged in.", this.Player );
  }
  
  function ChangePassword( password ) {
    if ( !this.Reg ) return ::MessagePlayer( "[#7bb215][RLC] [#cc3510](ERROR) This account is not registered yet, use /register to register this account.", this.Player );
    if ( !this.Log ) return ::MessagePlayer( "[#7bb215][RLC] [#cc3510](ERROR) You are not logged in, use /login to login to this account.", this.Player );
    if ( !password ) return ::MessagePlayer( "[#7bb215][RLC] [#cc3510](ERROR) Usage: /changepass <old-pssword> <new-password>.", this.Player );
    
    local arrPass = ::split( password, " " );
    if ( arrPass.len() < 2 ) return ::MessagePlayer( "[#7bb215][RLC] [#cc3510](ERROR) Usage: /changepass <old-pssword> <new-password>.", this.Player );
    
    local hOldPassword = ::SHA256( arrPass[0] );
    local hNewPassword = ::SHA256( arrPass[1] );
    if ( hOldPassword != this.accPass ) return ::MessagePlayer( "[#7bb215][RLC] [#cc3510](ERROR) Incorrect old password.", this.Player );
    
    this.accPass = hNewPassword;
    ::QuerySQL( dbRLC, "UPDATE rlc_accounts SET p_password='"+this.accPass+"' WHERE p_unique_id LIKE '"+this.accID+"'" );
    ::MessagePlayer( "[#7bb215][RLC] [#11c6bd]The account pssword has been changed from "+arrPass[0]+" to "+arrPass[1]+", don't forget the password.", this.Player );
  }
}
