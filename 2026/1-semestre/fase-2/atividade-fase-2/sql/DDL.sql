-- ============================================================
-- Vinheria Agnello — DDL Script
-- Compatível com: Azure SQL e SQL Server local (Docker)
-- Idempotente: pode ser executado mais de uma vez sem erro
-- ============================================================

IF OBJECT_ID('dbo.users', 'U') IS NULL
BEGIN
    CREATE TABLE users (
        id            INT IDENTITY(1,1) PRIMARY KEY,
        username      NVARCHAR(50)  NOT NULL UNIQUE,
        email         NVARCHAR(100) NOT NULL UNIQUE,
        password_hash NVARCHAR(64)  NOT NULL,  -- SHA-256 hex (64 chars)
        created_at    DATETIME DEFAULT GETDATE()
    );
END

IF OBJECT_ID('dbo.wines', 'U') IS NULL
BEGIN
    CREATE TABLE wines (
        id              INT IDENTITY(1,1) PRIMARY KEY,
        name            NVARCHAR(100)  NOT NULL,
        grape           NVARCHAR(100),
        country         NVARCHAR(50),
        region          NVARCHAR(100),
        type            NVARCHAR(20),    -- Tinto | Branco | Rosé | Espumante
        vintage         INT,
        price           DECIMAL(10, 2)  NOT NULL,
        alcohol_content DECIMAL(4, 1),
        description     NVARCHAR(MAX),
        image_url       NVARCHAR(500),   -- URL do Azure Blob Storage (preenchida depois)
        is_featured     BIT DEFAULT 0,
        created_at      DATETIME DEFAULT GETDATE()
    );
END
