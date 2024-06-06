SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Genres](
	[genreId] [int] NOT NULL,
	[genreName] [varchar](64) NULL,
PRIMARY KEY CLUSTERED 
(
	[genreId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Titles](
	[tConst] [varchar](20) NULL,
	[FK_titleTypeId] [int] NULL,
	[primaryTitle] [varchar](512) NULL,
	[originalTitle] [varchar](512) NULL,
	[isAdult] [bit] NULL,
	[startYear] [int] NULL,
	[endYear] [int] NULL,
	[runTimeMinuttes] [int] NULL,
	[titleId] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[titleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TitleTypes](
	[titleTypeId] [int] NOT NULL,
	[titleType] [varchar](64) NULL,
PRIMARY KEY CLUSTERED 
(
	[titleTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Professions](
	[profId] [int] NOT NULL,
	[profName] [varchar](128) NULL,
PRIMARY KEY CLUSTERED 
(
	[profId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Names](
	[nConst] [varchar](20) NULL,
	[primaryName] [varchar](256) NULL,
	[birthYear] [int] NULL,
	[deathYear] [int] NULL
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GenreTitles](
	[FK_titleId] [varchar](20) NULL,
	[FK_genreId] [int] NULL
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[KnownFors](
	[FK_nameId] [varchar](20) NOT NULL,
	[FK_titleId] [varchar](20) NOT NULL
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[NamesProfessions](
	[FK_nameId] [varchar](20) NOT NULL,
	[FK_profId] [int] NOT NULL
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TitleProfessionNames](
	[FK_nameId] [varchar](20) NOT NULL,
	[FK_titleId] [varchar](20) NOT NULL,
	[FK_profId] [int] NOT NULL
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[AddTitle]
    @titleTypeName varchar(30),
    @primaryTitle varchar(512),
    @originalTitle varchar(512),
    @isAdult bit,
    @startYear int,
    @endYear int,
    @runTimeMinutes int,
    @genre varchar(512)

AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @titleTypeId int;
    SET @titleTypeId = (SELECT titleTypeId FROM TitleTypes WHERE @titleTypeName = titleType);

    DECLARE @TitleNewID  varchar(20)
    EXEC NewTitleId101 @newId = @TitleNewID OUTPUT;

    INSERT INTO Titles VALUES (@TitleNewID, @titleTypeId, @primaryTitle, @originalTitle, @isAdult, @startYear, @endYear, @runTimeMinutes);

    DECLARE @tempGenreName varchar(64);

    DECLARE genre_cursor CURSOR FOR SELECT VALUE FROM string_split(@genre, ',')

    OPEN genre_cursor;
        FETCH NEXT FROM genre_cursor INTO @tempGenreName

    WHILE @@FETCH_STATUS = 0
    BEGIN 
        DECLARE @genreID int;
        SELECT @genreID = genreId FROM Genres WHERE genreName = TRIM(@tempGenreName)

        IF @genreID IS NOT NULL 
        BEGIN
            INSERT INTO GenreTitles (FK_titleId, FK_genreId) VALUES (@TitleNewID, @genreID)
        END
    FETCH NEXT FROM genre_cursor INTO @tempGenreName
    END

Close genre_cursor
DEALLOCATE genre_cursor
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[NewTitleId101]
    @NewId varchar(20) OUTPUT

AS
BEGIN 
    SET NOCOUNT ON;

    DECLARE @currentId int;
    SELECT @currentId = TitleIdCounter FROM NewTitleId;
    SET @currentId = @currentId + 1;

    UPDATE NewTitleId SET TitleIdCounter = @currentId;


    SET @newId = CAST(@currentId AS VARCHAR(20));
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[WildcardSearchNames101]
    @pattern NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    IF (1=1)
    BEGIN
        SET @pattern = @pattern + '%';
    END

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        SELECT *
        FROM Names
        WHERE primaryName LIKE @pattern
        ORDER BY primaryName ASC';

    EXEC sp_executesql @sql, N'@pattern NVARCHAR(100)', @pattern;
END;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[WildcardSearchTitles101]
    @pattern NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    IF (1=1)
    BEGIN
        SET @pattern = @pattern + '%';
    END

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
         SELECT *
        FROM Titles
        WHERE primaryTitle LIKE @pattern OR originalTitle LIKE @pattern
        ORDER BY primaryTitle ASC';

    EXEC sp_executesql @sql, N'@pattern NVARCHAR(100)', @pattern;
END;
