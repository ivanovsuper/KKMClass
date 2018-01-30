unit uKKMClass;

interface
uses
  Classes, COMObj, Forms, SysUtils, Variants;
type
  TCheck = class;
  TChecks = class;
  TCheckGoods = class;
  TKKM = class;
  TKKMErrors =
    ( kkmeNoErrors,
      kkmeNoConnection,
      kkmeErrorCashierPasswordSet,
      kkmeErrorAdminPasswordSet,
      kkmeErrorSysAdminPasswordSet,
      kkmeErrorClosingOpenedCheck,
      kkmeErrorPaymentLessThenCheckSum,
      kkmeErrorRegistration,
      kkmeErrorReturn,
      kkmeErrorPercentDiscountPerPosition,
      kkmeErrorSumDiscountPerPosition,
      kkmeErrorPercentDiscountPerCheck,
      kkmeErrorSumDiscountPerCheck,
      kkmeErrorPayment0,
      kkmeErrorPayment1,
      kkmeErrorPayment2,
      kkmeErrorPayment3,
      kkmeErrorCloseCheck,
      kkmeErrorXReport,
      kkmeErrorZReport,
      kkmeErrorIncome,
      kkmeErrorOutcome
      );
  TRegType = (rtSell, rtReturn);
  TCheckGood = class(TCollectionItem)
  private
    FGoodPrice: Double;
    FGoodCaption: String;
    FGoodAmount: Double;
    FGoods: TCheckGoods;
    FSumDiscount: Double;
    FPercentDiscount: Double;
    FDepartment: Integer;
    function GetCheck: TCheck;
    function GetGoodSum: Double;
  public
    constructor Create(Collection: TCollection);override;
  published
    property Goods: TCheckGoods read FGoods;
    property Check: TCheck read GetCheck;
    property GoodCaption: String read FGoodCaption write FGoodCaption;
    property GoodAmount: Double read FGoodAmount write FGoodAmount;
    property GoodPrice: Double read FGoodPrice write FGoodPrice;
    property SumDiscount: Double read FSumDiscount write FSumDiscount;
    property PercentDiscount: Double read FPercentDiscount write FPercentDiscount;
    property Department: Integer read FDepartment write FDepartment;
    property GoodSum: Double read GetGoodSum; 
  end;
  TCheckGoods = class(TCollection)
    FCheck: TCheck;
  private
    function GetGoods(Index: Integer): TCheckGood;
  published
  public
    function AddGood: TCheckGood;
    constructor Create(ACheck: TCheck);
    property Check: TCheck read FCheck;
    property Goods[Index: Integer]: TCheckGood read GetGoods;default;
  end;
  TCheck = class(TCollectionItem)
  private
    FGoods: TCheckGoods;
    FChecks: TChecks;
    FDepartment: Integer;
    FPercentDiscount: Double;
    FSumDiscount: Double;
    FChange: Double;
    FKKMNumber: Integer;
    FRegType: TRegType;
    FSuccess: Boolean;
    function GetKKM: TKKM;
    procedure SetDepartment(const Value: Integer);
    function GetCheckSum: Double;
  public
    constructor Create(Collection: TCollection);override;
    destructor Destroy;override;
    property Goods: TCheckGoods read FGoods;
    property Checks: TChecks read FChecks;
    property KKM: TKKM read GetKKM;
    property Department: Integer read FDepartment write SetDepartment;
    property SumDiscount: Double read FSumDiscount write FSumDiscount;
    property PercentDiscount: Double read FPercentDiscount write FPercentDiscount;
    property CheckSum: Double read GetCheckSum;
    property Change: Double read FChange write FChange;
    property KKMNumber: Integer read FKKMNumber write FKKMNumber;
    property RegType: TRegType read FRegType write FRegType;
    property Success: Boolean read FSuccess write FSuccess;
  end;
  TChecks = class(TCollection)
  FKKM: TKKM;
  private
    function GetCheck(Index: Integer): TCheck;
  public
    constructor Create(AKKM: TKKM);
    function AddCheck: TCheck;
    property Checks[Index: Integer]: TCheck read GetCheck;default;
    property KKM: TKKM read FKKM;
  end;
  TKKM = class(TComponent)
  private
    FChecks: TChecks;
    FActive: Boolean;
    FCashierPassword: String;
    FAdministratorPassword: String;
    FSystemAdministratorPassword: String;
    FEnabled: Boolean;
    FLastError: TKKMErrors;
    FIgnoreErrors: Boolean;
    procedure SetActive(const Value: Boolean);virtual;
  public
    constructor Create(AOwner: TComponent);override;
    function Sell(Check: TCheck): Boolean;overload;virtual;
    function Sell(Check: TCheck; Cash: Double; Cashless1: Double = 0; Cashless2: Double = 0; Cashless3: Double = 0): Boolean;overload;virtual;
    function Return(Check: TCheck): Boolean;overload;
    function Return(Check: TCheck; Cash: Double; Cashless1: Double = 0; Cashless2: Double = 0; Cashless3: Double = 0): Boolean;overload;virtual;
    function Income(Sum: Double): Boolean;virtual;
    function Outcome(Sum: Double): Boolean;virtual;
    function XReport: Boolean;virtual;
    function ZReport: Boolean;virtual;
    function ValueByName(ValueName: String): Variant;virtual;
    function SetValueByName(ValueName: String; Value: Variant): Boolean;virtual;
    function SetDeviceProperties: Boolean;virtual;abstract;
  published
    property Active: Boolean read FActive write SetActive;
    property Enabled: Boolean read FEnabled;
    property CashierPassword: String read FCashierPassword write FCashierPassword;
    property AdministratorPassword: String read FAdministratorPassword write FAdministratorPassword;
    property SystemAdministratorPassword: String read FSystemAdministratorPassword write FSystemAdministratorPassword;
    property Checks: TChecks read FChecks;
    property LastError: TKKMErrors read FLastError write FLastError;
    property IgnoreErrors: Boolean read FIgnoreErrors write FIgnoreErrors;
  end;

  TFelixFRKKM = class(TKKM)
  private
    ECR: OleVariant;
    procedure SetActive(const Value: Boolean);override;
  public
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    function Sell(Check: TCheck; Cash: Double; Cashless1: Double = 0; Cashless2: Double = 0; Cashless3: Double = 0): Boolean;overload;override;
    function Return(Check: TCheck; Cash: Double; Cashless1: Double = 0; Cashless2: Double = 0; Cashless3: Double = 0): Boolean;overload;override;
    function Income(Sum: Double): Boolean;override;
    function Outcome(Sum: Double): Boolean;override;
    function XReport: Boolean;override;
    function ZReport: Boolean;override;
    function ValueByName(ValueName: String): Variant;override;
    function SetValueByName(ValueName: String; Value: Variant): Boolean;override;
    function SetDeviceProperties: Boolean;override;
  end;
implementation

{ TCheckGood }

constructor TCheckGood.Create(Collection: TCollection);
begin
  inherited;
  FGoodPrice:=0;
  FGoodCaption:='';
  FGoodAmount:=0;
  FGoods:=TCheckGoods(Collection);
end;

function TCheckGood.GetCheck: TCheck;
begin
  Result:=Goods.Check;
end;

function TCheckGood.GetGoodSum: Double;
begin
  Result:=GoodPrice*GoodAmount*(1-PercentDiscount/100)-SumDiscount;
end;

{ TCheckGoods }

function TCheckGoods.AddGood: TCheckGood;
begin
  Result:=TCheckGood.Create(Self);
end;

constructor TCheckGoods.Create(ACheck: TCheck);
begin
  inherited Create(TCheckGood);
  FCheck:=ACheck;
end;

function TCheckGoods.GetGoods(Index: Integer): TCheckGood;
begin
  Result:=TCheckGood(inherited Items[Index]);
end;

{ TCheck }

constructor TCheck.Create(Collection: TCollection);
begin
  inherited;
  FChecks:=TChecks(Collection);
  FGoods:=TCheckGoods.Create(Self);
end;

destructor TCheck.Destroy;
begin
  FGoods.Free;
  inherited;
end;

function TCheck.GetCheckSum: Double;
var
  i: Integer;
begin
  Result:=0;
  for i := 0 to Goods.Count - 1 do
  begin
    Result:=Result+Goods[i].GoodSum;
  end;
  Result:=Result*(1-PercentDiscount/100)-SumDiscount;
  Result:=Round(Result*100)/100;
end;

function TCheck.GetKKM: TKKM;
begin
  Result:=Checks.KKM;
end;

procedure TCheck.SetDepartment(const Value: Integer);
var
  i: Integer;
begin
  FDepartment := Value;
  for i := 0 to Goods.Count - 1 do
    Goods[i].Department:=Value;
end;

{ TChecks }

function TChecks.AddCheck: TCheck;
begin
  Result:=TCheck.Create(Self);
end;

constructor TChecks.Create(AKKM: TKKM);
begin
  inherited Create(TCheck);
  FKKM:=AKKM;
end;

function TChecks.GetCheck(Index: Integer): TCheck;
begin
  Result:=TCheck(inherited Items[Index]);
end;

{ TKKM }

constructor TKKM.Create(AOwner: TComponent);
begin
  inherited;
  FChecks:=TChecks.Create(Self);
  FEnabled:=True;
end;

function TKKM.Income(Sum: Double): Boolean;
begin
  Result:=False;
  if not Active then
    Active:=True;
  if not Active then
  begin
    LastError:=kkmeNoConnection;
    Exit;
  end;
  LastError:=kkmeNoErrors;
end;

function TKKM.Outcome(Sum: Double): Boolean;
begin
  Result:=False;
  if not Active then
    Active:=True;
  if not Active then
  begin
    LastError:=kkmeNoConnection;
    Exit;
  end;
  LastError:=kkmeNoErrors;
end;

function TKKM.Return(Check: TCheck; Cash, Cashless1, Cashless2,
  Cashless3: Double): Boolean;
begin
  Result:=False;
  Check.Success:=False;
  if not Active then
    Active:=True;
  if not Active then
  begin
    LastError:=kkmeNoConnection;
    Exit;
  end;
  LastError:=kkmeNoErrors;
  Check.RegType:=rtReturn;
end;

function TKKM.Return(Check: TCheck): Boolean;
begin
  Result:=Return(Check, Check.CheckSum);
end;

function TKKM.Sell(Check: TCheck): Boolean;
begin
  Result:=Sell(Check, Check.CheckSum);
end;

function TKKM.Sell(Check: TCheck; Cash: Double; Cashless1: Double = 0; Cashless2: Double = 0; Cashless3: Double = 0): Boolean;
var
  SumCashlessIncome:Double;
  SumIncome:Double;
begin
  Result:=False;
  Check.Success:=False;
  if not Active then
    Active:=True;
  if not Active then
  begin
    LastError:=kkmeNoConnection;
    Exit;
  end;
  LastError:=kkmeNoErrors;
  SumCashlessIncome:=Cashless1+Cashless2+Cashless3;
  SumIncome:=Cash+SumCashlessIncome;
  Result:=SumIncome>Check.CheckSum; //Сумма оплаты должна быть больше суммы чека
  if not Result then
  begin
    LastError:=kkmeErrorPaymentLessThenCheckSum;
    if not IgnoreErrors then Exit;
  end;
  Check.RegType:=rtSell;
end;

procedure TKKM.SetActive(const Value: Boolean);
begin
  if not Enabled then
    FActive:=False
  else
    FActive := Value;
end;

function TKKM.SetValueByName(ValueName: String; Value: Variant): Boolean;
begin
  Result:=False;
  if not Active then
    Active:=True;
  if not Active then
  begin
    LastError:=kkmeNoConnection;
    Exit;
  end;
  LastError:=kkmeNoErrors;
end;

function TKKM.ValueByName(ValueName: String): Variant;
begin
  Result:=NULL;
  if not Active then
    Active:=True;
  if not Active then
  begin
    LastError:=kkmeNoConnection;
    Exit;
  end;
  LastError:=kkmeNoErrors;
end;

function TKKM.XReport: Boolean;
begin
  Result:=False;
  if not Active then
    Active:=True;
  if not Active then
  begin
    LastError:=kkmeNoConnection;
    Exit;
  end;
  LastError:=kkmeNoErrors;
end;

function TKKM.ZReport: Boolean;
begin
  Result:=False;
  if not Active then
    Active:=True;
  if not Active then
  begin
    LastError:=kkmeNoConnection;
    Exit;
  end;
  LastError:=kkmeNoErrors;
end;

{ TFelixFRKKM }

constructor TFelixFRKKM.Create(AOwner: TComponent);
begin
  inherited;
  // создаем объект общего драйвера ККМ
  // если объект создать не удается генерируется исключение, по которому завершается работа приложения
  try
    ECR := CreateOleObject('AddIn.FprnM45');
    ECR.ApplicationHandle := Application.Handle; // необходимо для корректного отображения окон драйвера в контексте приложения
  except
    FEnabled:=False;
  end;
end;

destructor TFelixFRKKM.Destroy;
begin
  ECR:=0;
  inherited;
end;

function TFelixFRKKM.Income(Sum: Double): Boolean;
begin
  Result:=inherited Income(Sum);
  if LastError <> kkmeNoErrors then
  begin
    if IgnoreErrors then Exit;
  end;
  ECR.Summ := Sum;
  Result:=ECR.CashIncome=0;
  if not Result then
    LastError:=kkmeErrorIncome;
end;

function TFelixFRKKM.Outcome(Sum: Double): Boolean;
begin
  Result:=inherited Outcome(Sum);
  if LastError <> kkmeNoErrors then
  begin
    if IgnoreErrors then Exit;
  end;
  ECR.Summ := Sum;
  Result:=ECR.CashOutcome=0;
  if not Result then
    LastError:=kkmeErrorOutcome;
end;

function TFelixFRKKM.Return(Check: TCheck; Cash: Double; Cashless1: Double = 0; Cashless2: Double = 0; Cashless3: Double = 0): Boolean;
var
  i: Integer;
  SumCashlessIncome: Double;
  SumIncome: Double;
begin
  Result:=inherited Return(Check, Cash, Cashless1, Cashless2, Cashless3);
  if LastError <> kkmeNoErrors then
  begin
    if IgnoreErrors then Exit;
  end;
  Result:=ECR.CheckState=0; //Открытый чек
  if not Result then
    Result:=ECR.CancelCheck=0; //Пытаемся отменить
  if not Result then
  begin
    LastError:=kkmeErrorPaymentLessThenCheckSum;
    if not IgnoreErrors then Exit;
  end;
  SumCashlessIncome:=Cashless1+Cashless2+Cashless3;
  SumIncome:=Cash+SumCashlessIncome;
  if SumIncome>Check.CheckSum then
  begin
    if Cash>SumIncome-Check.CheckSum then
      Cash:=Check.CheckSum-SumCashlessIncome
    else
    begin
      LastError:=kkmeErrorPaymentLessThenCheckSum;
      if not IgnoreErrors then Exit;
    end;
  end;
// входим в режим регистрации
  // устанавливаем пароль кассира
  ECR.Password := StrToInt(CashierPassword);
  // входим в режим регистрации
  ECR.Mode := 1;
  Result:=ECR.SetMode=0;
  if not Result then
  begin
    LastError:=kkmeErrorCashierPasswordSet;
    if not IgnoreErrors then Exit;
  end;
// возврат
  for i := 0 to Check.Goods.Count - 1 do
  begin
    if Result then
    begin
    // регистрация возврата
      ECR.Name := Check.Goods[i].GoodCaption;
      ECR.Price := Check.Goods[i].GoodPrice;
      ECR.Quantity := Check.Goods[i].GoodAmount;
      ECR.Department := Check.Goods[i].Department;
      Result:=ECR.Return=0;
      if not Result then
      begin
        LastError:=kkmeErrorReturn;
        if not IgnoreErrors then Exit;
      end;
    end;
    if Result then
    begin
      if Check.Goods[i].PercentDiscount<>0 then
      begin
        ECR.Percents := Abs(Check.Goods[i].PercentDiscount);
        ECR.Destination := 1;//На позицию
        if Check.Goods[i].PercentDiscount>0 then
          Result:=ECR.PercentsDiscount=0
        else
          Result:=ECR.PercentsCharge=0;
        if not Result then
        begin
          LastError:=kkmeErrorPercentDiscountPerPosition;
          if not IgnoreErrors then Exit;
        end;
      end;
    end;
    if Result then
    begin
      if Check.Goods[i].SumDiscount<>0 then
      begin
        ECR.Summ := Abs(Check.Goods[i].SumDiscount);
        ECR.Destination := 1;//На позицию
        if Check.Goods[i].SumDiscount>0 then
          Result:=ECR.SummDiscount=0
        else
          Result:=ECR.SummCharge=0;
        if not Result then
        begin
          LastError:=kkmeErrorSumDiscountPerPosition;
          if not IgnoreErrors then Exit;
        end;
      end;
    end;
  end;
  if Result then
  begin
    if Check.PercentDiscount<>0 then
    begin
      ECR.Percents := Abs(Check.PercentDiscount);
      ECR.Destination := 0;//На весь чек
      if Check.PercentDiscount>0 then
        Result:=ECR.PercentsDiscount=0
      else
        Result:=ECR.PercentsCharge=0;
      if not Result then
      begin
        LastError:=kkmeErrorPercentDiscountPerCheck;
        if not IgnoreErrors then Exit;
      end;
    end;
  end;
  if Result then
  begin
    if Check.SumDiscount<>0 then
    begin
      ECR.Summ := Abs(Check.SumDiscount);
      ECR.Destination := 0;//На весь чек
      if Check.SumDiscount>0 then
        Result:=ECR.SummDiscount=0
      else
        Result:=ECR.SummCharge=0;
      if not Result then
      begin
        LastError:=kkmeErrorSumDiscountPerCheck;
        if not IgnoreErrors then Exit;
      end;
    end;
  end;
  if Result then
  begin
    if Cashless1<>0 then
    begin
      ECR.Summ:=Cashless1;
      ECR.TypeClose:=1;//Тип оплаты 1
      Result:=ECR.StornoPayment;
      if not Result then
      begin
        LastError:=kkmeErrorPayment1;
        if not IgnoreErrors then Exit;
      end;
    end;
  end;
  if Result then
  begin
    if Cashless2<>0 then
    begin
      ECR.Summ:=Cashless2;
      ECR.TypeClose:=2;//Тип оплаты 2
      Result:=ECR.StornoPayment;
      if not Result then
      begin
        LastError:=kkmeErrorPayment2;
        if not IgnoreErrors then Exit;
      end;
    end;
  end;
  if Result then
  begin
    if Cashless3<>0 then
    begin
      ECR.Summ:=Cashless3;
      ECR.TypeClose:=3;//Тип оплаты 3
      Result:=ECR.StornoPayment;
      if not Result then
      begin
        LastError:=kkmeErrorPayment3;
        if not IgnoreErrors then Exit;
      end;
    end;
  end;
  if Result then
  begin
    ECR.Summ:=Cash;
    ECR.TypeClose:=0;//Наличные
    Result:=ECR.StornoPayment;
    if not Result then
    begin
      LastError:=kkmeErrorPayment0;
      if not IgnoreErrors then Exit;
    end;
    Check.Change:=ECR.Change;
  end;
  if Result then
  begin
    Check.KKMNumber:=ECR.CheckNumber;
  end;
  if Result then
  begin
    Result:=ECR.CloseCheck;//Закрытие чека
    if not Result then
    begin
      LastError:=kkmeErrorCloseCheck;
      if not IgnoreErrors then Exit;
    end;
  end;
  Check.Success:=Result;
end;

function TFelixFRKKM.Sell(Check: TCheck; Cash: Double; Cashless1: Double = 0; Cashless2: Double = 0; Cashless3: Double = 0): Boolean;
var
  i: Integer;
begin
  Result:=inherited Sell(Check, Cash, Cashless1, Cashless2, Cashless3);
  if LastError <> kkmeNoErrors then
  begin
    if IgnoreErrors then Exit;
  end;
  Result:=ECR.CheckState=0; //Открытый чек
  if not Result then
    Result:=ECR.CancelCheck=0; //Пытаемся отменить
  if not Result then
  begin
    LastError:=kkmeErrorPaymentLessThenCheckSum;
    if not IgnoreErrors then Exit;
  end;

// продажа со сдачей
// входим в режим регистрации
  // устанавливаем пароль кассира
  ECR.Password := StrToInt(CashierPassword);
  // входим в режим регистрации
  ECR.Mode := 1;
  Result:=ECR.SetMode=0;
  if not Result then
  begin
    LastError:=kkmeErrorCashierPasswordSet;
    if not IgnoreErrors then Exit;
  end;
  // регистрация продажи
  for i := 0 to Check.Goods.Count - 1 do
  begin
    if Result then
    begin
      ECR.Name := Check.Goods[i].GoodCaption;
      ECR.Price := Check.Goods[i].GoodPrice;
      ECR.Quantity := Check.Goods[i].GoodAmount;
      ECR.Department := Check.Goods[i].Department;
      Result:=ECR.Registration=0;
      if not Result then
      begin
        LastError:=kkmeErrorRegistration;
        if not IgnoreErrors then Exit;
      end;
    end;
    if Result then
    begin
      if Check.Goods[i].PercentDiscount<>0 then
      begin
        ECR.Percents := Abs(Check.Goods[i].PercentDiscount);
        ECR.Destination := 1;//На позицию
        if Check.Goods[i].PercentDiscount>0 then
          Result:=ECR.PercentsDiscount=0
        else
          Result:=ECR.PercentsCharge=0;
        if not Result then
        begin
          LastError:=kkmeErrorPercentDiscountPerPosition;
          if not IgnoreErrors then Exit;
        end;
      end;
    end;
    if Result then
    begin
      if Check.Goods[i].SumDiscount<>0 then
      begin
        ECR.Summ := Abs(Check.Goods[i].SumDiscount);
        ECR.Destination := 1;//На позицию
        if Check.Goods[i].SumDiscount>0 then
          Result:=ECR.SummDiscount=0
        else
          Result:=ECR.SummCharge=0;
        if not Result then
        begin
          LastError:=kkmeErrorSumDiscountPerPosition;
          if not IgnoreErrors then Exit;
        end;
      end;
    end;
  end;
  if Result then
  begin
    if Check.PercentDiscount<>0 then
    begin
      ECR.Percents := Abs(Check.PercentDiscount);
      ECR.Destination := 0;//На весь чек
      if Check.PercentDiscount>0 then
        Result:=ECR.PercentsDiscount=0
      else
        Result:=ECR.PercentsCharge=0;
      if not Result then
      begin
        LastError:=kkmeErrorPercentDiscountPerCheck;
        if not IgnoreErrors then Exit;
      end;
    end;
  end;
  if Result then
  begin
    if Check.SumDiscount<>0 then
    begin
      ECR.Summ := Abs(Check.SumDiscount);
      ECR.Destination := 0;//На весь чек
      if Check.SumDiscount>0 then
        Result:=ECR.SummDiscount=0
      else
        Result:=ECR.SummCharge=0;
      if not Result then
      begin
        LastError:=kkmeErrorSumDiscountPerCheck;
        if not IgnoreErrors then Exit;
      end;
    end;
  end;
  if Result then
  begin
    if Cashless1<>0 then
    begin
      ECR.Summ:=Cashless1;
      ECR.TypeClose:=1;//Тип оплаты 1
      Result:=ECR.Payment;
      if not Result then
      begin
        LastError:=kkmeErrorPayment1;
        if not IgnoreErrors then Exit;
      end;
    end;
  end;
  if Result then
  begin
    if Cashless2<>0 then
    begin
      ECR.Summ:=Cashless2;
      ECR.TypeClose:=2;//Тип оплаты 2
      Result:=ECR.Payment;
      if not Result then
      begin
        LastError:=kkmeErrorPayment2;
        if not IgnoreErrors then Exit;
      end;
    end;
  end;
  if Result then
  begin
    if Cashless3<>0 then
    begin
      ECR.Summ:=Cashless3;
      ECR.TypeClose:=3;//Тип оплаты 3
      Result:=ECR.Payment;
      if not Result then
      begin
        LastError:=kkmeErrorPayment3;
        if not IgnoreErrors then Exit;
      end;
    end;
  end;
  if Result then
  begin
    ECR.Summ:=Cash;
    ECR.TypeClose:=0;//Наличные
    Result:=ECR.Payment;
    if not Result then
    begin
      LastError:=kkmeErrorPayment0;
      if not IgnoreErrors then Exit;
    end;
    Check.Change:=ECR.Change;
  end;
  if Result then
  begin
    Check.KKMNumber:=ECR.CheckNumber;
  end;
  if Result then
  begin
    Result:=ECR.CloseCheck;//Закрытие чека
    if not Result then
    begin
      LastError:=kkmeErrorCloseCheck;
      if not IgnoreErrors then Exit;
    end;
  end;
  Check.Success:=Result;
end;

procedure TFelixFRKKM.SetActive(const Value: Boolean);
begin
  inherited;
  if Value then
  begin
    // занимаем порт
    ECR.DeviceEnabled := true;
    if ECR.ResultCode <> 0 then
      FActive:=False;
  end
  else
  begin
    // занимаем порт
    ECR.DeviceEnabled := false;
    FActive:=False;
  end;
end;

function TFelixFRKKM.SetDeviceProperties: Boolean;
begin
  ECR.ShowProperties;
end;

function TFelixFRKKM.SetValueByName(ValueName: String; Value: Variant): Boolean;
begin
  Result:=inherited SetValueByName(ValueName, Value);
  if LastError <> kkmeNoErrors then
  begin
    if IgnoreErrors then Exit;
  end;
  if ValueName = 'IsFiscal' then
    Result:=False
  else
  begin
    ECR.ValuePurpose:=StrToInt(ValueName);
    ECR.Value:=Value;
    Result:=ECR.SetValue=0;
  end;
end;

function TFelixFRKKM.ValueByName(ValueName: String): Variant;
begin
  Result:=inherited ValueByName(ValueName);
  if LastError <> kkmeNoErrors then
  begin
    if IgnoreErrors then Exit;
  end;
  if ValueName = 'IsFiscal' then
    Result:=ECR.IsFiscal
  else
  begin
    ECR.ValuePurpose:=StrToInt(ValueName);
    ECR.GetValue;
    Result:=ECR.Value;
  end;
end;

function TFelixFRKKM.XReport: Boolean;
begin
  Result:=inherited XReport;
  if not Result then
    if IgnoreErrors then
    begin
      // устанавливаем пароль администратора
      ECR.Password := StrToInt(AdministratorPassword);
      // входим в режим отчетов без гашения
      ECR.Mode := 2;
      Result:=ECR.SetMode=0;
      if not Result then
      begin
        LastError:=kkmeErrorAdminPasswordSet;
        if not IgnoreErrors then Exit;
      end;
      // снимаем отчет
      ECR.ReportType := 2;
      Result:=ECR.Report=0;
      if not Result then
        LastError:=kkmeErrorXReport;
      ECR.ResetMode;
    end;
end;

function TFelixFRKKM.ZReport: Boolean;
begin
  Result:=inherited ZReport;
  if not Result then
    if IgnoreErrors then
    begin
      // устанавливаем пароль администратора
      ECR.Password := StrToInt(AdministratorPassword);
      // входим в режим отчетов без гашения
      ECR.Mode := 3;
      Result:=ECR.SetMode=0;
      if not Result then
      begin
        LastError:=kkmeErrorSysAdminPasswordSet;
        if not IgnoreErrors then Exit;
      end;
      // снимаем отчет
      ECR.ReportType := 12;
      Result:=ECR.Report=0;
      if not Result then
        LastError:=kkmeErrorZReport;
      ECR.ResetMode;
    end;
end;

end.
