CREATE TABLE [dbo].[testmasking] (
    [CPF]      VARCHAR (20) MASKED WITH (FUNCTION = 'partial(3, "XXXXX", 3)') NULL,
    [Nome]     VARCHAR (50)                                                   NULL,
    [Telefone] VARCHAR (20)                                                   NULL
);


GO

