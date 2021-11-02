unit Model.Usuario;

interface

uses FireDAC.Comp.Client, BCrypt, Data.DB, System.SysUtils, Model.Connection,
     Provider.AUTHORIZATION;

type
    TUsuario = class
    private
      FID: Integer;
      FSTATUS: Integer;
      FPASSWORD: String;
      FUSERNAME: String;
    public
      constructor Create;
      destructor Destroy; override;

      property ID : Integer read FID write FID;
      property USERNAME : String read FUSERNAME write FUSERNAME;
      property PASSWORD : String read FPASSWORD write FPASSWORD;
      property STATUS : Integer read FSTATUS write FSTATUS;

      function ListarUsuario(order_by: string; out erro: string): TFDQuery;
      function Inserir(out erro: string): Boolean;
      function Excluir(out erro: string): Boolean;
      function Editar(out erro: string): Boolean;
      function Auth(Username, Password: String): Boolean;
end;

implementation

{ TUsuario }

function TUsuario.Auth(Username, Password: String): Boolean;
var
  qry   : TFDQuery;
  LHash : String;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Model.Connection.FConnection;

    with qry do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT * FROM usuarios WHERE 1 = 1');
      SQL.Add('   AND UPPER(USERNAME) = UPPER( :USERNAME ) ');
      ParamByName('USERNAME').AsString := USERNAME;
      Open;
    end;


    if not qry.IsEmpty then
    begin
      if TBCrypt.CompareHash(Password,qry.FieldByName('PASSWORD').AsString) then
      begin
        mUsuario := qry.FieldByName('USERNAME').AsString;
        mID      := qry.FieldByName('ID')      .AsString;
        Result   := True;
      end
      else
        Result := False;
    end
    else
      Result := False;

  except
    on ex: exception do
      Result := False;
  end;

end;

constructor TUsuario.Create;
begin
    Model.Connection.Connect;
end;

destructor TUsuario.Destroy;
begin
    Model.Connection.Disconect;
end;

function TUsuario.Excluir(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('DELETE FROM usuarios WHERE ID=:ID');
            ParamByName('ID').Value := ID;
            ExecSQL;
        end;

        qry.Free;
        erro := '';
        result := true;

    except on ex:exception do
        begin
            erro := 'Erro ao excluir usuario: ' + ex.Message;
            Result := false;
        end;
    end;
end;

function TUsuario.Editar(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    // Validacoes...
    if ID <= 0 then
    begin
        Result := false;
        erro := 'Informe o id. usuario';
        exit;
    end;

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE usuarios SET USERNAME=:USERNAME, PASSWORD=:PASSWORD, STATUS=:STATUS');
            SQL.Add('WHERE ID=:ID');
            ParamByName('USERNAME').Value := USERNAME;
            ParamByName('PASSWORD').Value := PASSWORD;
            ParamByName('STATUS')  .Value := STATUS;
            ParamByName('ID')      .Value := ID;
            ExecSQL;
        end;

        qry.Free;
        erro := '';
        result := true;

    except on ex:exception do
        begin
            erro := 'Erro ao alterar usuario: ' + ex.Message;
            Result := false;
        end;
    end;
end;

function TUsuario.Inserir(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    // Validacoes...
    if USERNAME.IsEmpty then
    begin
        Result := false;
        erro := 'Informe o nome do usuario';
        exit;
    end;

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('INSERT INTO usuarios (USERNAME, PASSWORD, STATUS)');
            SQL.Add('VALUES(:USERNAME, :PASSWORD, :STATUS)');

            ParamByName('USERNAME').Value := USERNAME;
            ParamByName('PASSWORD').Value := PASSWORD;
            ParamByName('STATUS')  .Value := STATUS;

            ExecSQL;

            // Busca ID inserido...
            Params.Clear;
            SQL.Clear;
            SQL.Add('SELECT MAX(ID) AS ID FROM usuarios');
            SQL.Add('WHERE USERNAME=:USERNAME');
            ParamByName('USERNAME').Value := USERNAME;
            active := true;

            ID := FieldByName('ID').AsInteger;
        end;

        qry.Free;
        erro := '';
        result := true;

    except on ex:exception do
        begin
            erro := 'Erro ao cadastrar usuario: ' + ex.Message;
            Result := false;
        end;
    end;
end;

function TUsuario.ListarUsuario(order_by: string; out erro: string): TFDQuery;
var
    qry : TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Close;
            SQL.Clear;
            SQL.Add('SELECT * FROM usuarios WHERE 1 = 1');

            if ID > 0 then
            begin
                SQL.Add('AND ID = :ID');
                ParamByName('ID').Value := ID;
            end;

            if USERNAME <> '' then
            begin
                SQL.Add('AND USERNAME LIKE :USERNAME');
                ParamByName('USERNAME').Value := USERNAME;
            end;

            if order_by = '' then
                SQL.Add('ORDER BY 1')
            else
                SQL.Add('ORDER BY ' + order_by);

            Open;
        end;

        erro := '';
        Result := qry;
    except on ex:exception do
        begin
            erro := 'Erro ao consultar usuarios: ' + ex.Message;
            Result := nil;
        end;
    end;
end;

end.
