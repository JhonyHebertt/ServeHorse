unit Model.Categoria;

interface

uses FireDAC.Comp.Client, Data.DB, System.SysUtils, Model.Connection;

type
    TCategoria = class
    private
    FID: Integer;
    FDESCRICAO: String;
    public
        constructor Create;
        destructor Destroy; override;

        property ID : Integer read FID write FID;
        property DESCRICAO : String read FDESCRICAO write FDESCRICAO;

        function ListarCategoria(order_by: string; out erro: string): TFDQuery;
        function Inserir(out erro: string): Boolean;
        function Excluir(out erro: string): Boolean;
        function Editar(out erro: string): Boolean;
end;

implementation

{ TCategoria }

constructor TCategoria.Create;
begin
    Model.Connection.Connect;
end;

destructor TCategoria.Destroy;
begin
    Model.Connection.Disconect;
end;

function TCategoria.Excluir(out erro: string): Boolean;
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
            SQL.Add('DELETE FROM categorias WHERE ID=:ID');
            ParamByName('ID').Value := ID;
            ExecSQL;
        end;

        qry.Free;
        erro := '';
        result := true;

    except on ex:exception do
        begin
            erro := 'Erro ao excluir categoria: ' + ex.Message;
            Result := false;
        end;
    end;
end;

function TCategoria.Editar(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    // Validacoes...
    if ID <= 0 then
    begin
        Result := false;
        erro := 'Informe o ID. categoria';
        exit;
    end;

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE categorias SET DESCRICAO=:DESCRICAO');
            SQL.Add('WHERE ID=:ID');
            ParamByName('DESCRICAO').Value := DESCRICAO;
            ParamByName('ID')      .Value := ID;
            ExecSQL;
        end;

        qry.Free;
        erro := '';
        result := true;

    except on ex:exception do
        begin
            erro := 'Erro ao alterar categoria: ' + ex.Message;
            Result := false;
        end;
    end;
end;

function TCategoria.Inserir(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    // Validacoes...
    if DESCRICAO.IsEmpty then
    begin
        Result := false;
        erro := 'Informe o nome do categoria';
        exit;
    end;

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('INSERT INTO categorias (DESCRICAO)');
            SQL.Add('VALUES(:DESCRICAO)');

            ParamByName('DESCRICAO').Value := DESCRICAO;

            ExecSQL;

            // Busca ID inserido...
            Params.Clear;
            SQL.Clear;
            SQL.Add('SELECT MAX(ID) AS ID FROM categorias');
            SQL.Add('WHERE DESCRICAO=:DESCRICAO');
            ParamByName('DESCRICAO').Value := DESCRICAO;
            active := true;

            ID := FieldByName('ID').AsInteger;
        end;

        qry.Free;
        erro := '';
        result := true;

    except on ex:exception do
        begin
            erro := 'Erro ao cadastrar categoria: ' + ex.Message;
            Result := false;
        end;
    end;
end;

function TCategoria.ListarCategoria(order_by: string; out erro: string): TFDQuery;
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
            SQL.Add('SELECT * FROM categorias WHERE 1 = 1');

            if ID > 0 then
            begin
                SQL.Add('AND ID = :ID');
                ParamByName('ID').Value := ID;
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
            erro := 'Erro ao consultar categorias: ' + ex.Message;
            Result := nil;
        end;
    end;
end;

end.
