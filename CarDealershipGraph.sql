--Создание базы данных

USE master;
go

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'CarDealershipGraph')
BEGIN
    ALTER DATABASE CarDealershipGraph SET single_user WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CarDealershipGraph;
END

CREATE DATABASE CarDealershipGraph;
go

USE CarDealershipGraph;
go

--Создание таблиц узлов

-- УЗЕЛ 1: Марки автомобилей (Brands)
CREATE TABLE Brands (
    BrandID INT IDENTITY(1,1) PRIMARY KEY,
    BrandName NVARCHAR(100) NOT NULL UNIQUE,
    CountryOfOrigin NVARCHAR(100),
    YearFounded SMALLINT,
    Website NVARCHAR(500),
    IsManufacturerActive BIT DEFAULT 1,
    Description NVARCHAR(500)
) AS NODE;
GO

-- УЗЕЛ 2: Модели автомобилей (Models)
CREATE TABLE Models (
    ModelID INT IDENTITY(1,1) PRIMARY KEY,
    ModelName NVARCHAR(100) NOT NULL,
    ProductionStartYear SMALLINT,
    ProductionEndYear SMALLINT,
    BodyType NVARCHAR(50),
    EngineType NVARCHAR(50),
    Horsepower SMALLINT,
    FuelConsumption DECIMAL(4,1),
    TransmissionType NVARCHAR(50),
    BasePrice DECIMAL(12,2),
    IsElectric BIT DEFAULT 0,
    SafetyRating DECIMAL(3,2)
) AS NODE;
GO

-- УЗЕЛ 3: Сервисные центры (ServiceCenters)
CREATE TABLE ServiceCenters (
    CenterID INT IDENTITY(1,1) PRIMARY KEY,
    CenterName NVARCHAR(100) NOT NULL,
    Address NVARCHAR(255),
    PhoneNumber NVARCHAR(20),
    Email NVARCHAR(100),
    City NVARCHAR(100),
    Specialization NVARCHAR(255),
    OpenTime TIME,
    CloseTime TIME,
    Rating DECIMAL(3,2),
    IsOfficialDealer BIT DEFAULT 0
) AS NODE;
GO

-- УЗЕЛ 4: Клиенты (Customers)
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerFirstName NVARCHAR(100) NOT NULL,
    CustomerSecondName NVARCHAR(100),
    Email NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    City NVARCHAR(100),
    RegistrationDate DATE DEFAULT GETDATE(),
    LoyaltyLevel NVARCHAR(50) CHECK (LoyaltyLevel IN ('Bronze','Silver','Gold','Platinum'))
) AS NODE;
GO

--Создание таблиц рёбер

-- РЕБРО 1: BELONGS_TO (Модель принадлежит Марке)
-- Направление: Models -> Brands
CREATE TABLE BELONGS_TO AS EDGE;
GO

ALTER TABLE BELONGS_TO 
ADD CONSTRAINT EC_BELONGS_TO 
CONNECTION (Models TO Brands)
ON DELETE NO ACTION;
GO

ALTER TABLE BELONGS_TO 
ADD StartDate DATE,
    EndDate DATE,
    IsCurrentModel BIT DEFAULT 1;
GO

-- РЕБРО 2: SERVES (Сервисный центр обслуживает Марку)
-- Направление: ServiceCenters -> Brands
CREATE TABLE SERVES AS EDGE;
GO

ALTER TABLE SERVES 
ADD CONSTRAINT EC_SERVES 
CONNECTION (ServiceCenters TO Brands)
ON DELETE NO ACTION;
GO

ALTER TABLE SERVES 
ADD SpecializationLevel NVARCHAR(50) 
    CHECK (SpecializationLevel IN ('Официальный дилер', 'Авторизованный сервис', 'Специализированный ремонт', 'Универсальный')),
    ContractStartDate DATE,
    ContractEndDate DATE,
    ServiceQualityRating DECIMAL(3,2);
GO

-- РЕБРО 3: PURCHASED_BY (Модель куплена Клиентом)
-- Направление: Customers -> Models
CREATE TABLE PURCHASED_BY AS EDGE;
GO

ALTER TABLE PURCHASED_BY 
ADD CONSTRAINT EC_PURCHASED_BY 
CONNECTION (Customers TO Models)
ON DELETE CASCADE;
GO

ALTER TABLE PURCHASED_BY 
ADD PurchaseDate DATE NOT NULL DEFAULT GETDATE(),
    PurchasePrice DECIMAL(12,2),
    PaymentMethod NVARCHAR(50) CHECK (PaymentMethod IN ('Наличные', 'Банковская карта')),
    WarrantyYears INT,
    IsTradeIn BIT DEFAULT 0;
GO

--Заполнение таблиц узлов

-- Заполнение Brands
INSERT INTO Brands (BrandName, CountryOfOrigin, YearFounded, Website, IsManufacturerActive, Description) VALUES
('BMW', 'Germany', 1916, 'https://www.bmw.com', 1, 'Премиальные автомобили с акцентом на динамику'),
('Mercedes-Benz', 'Germany', 1926, 'https://www.mercedes-benz.com', 1, 'Роскошные автомобили и коммерческий транспорт'),
('Toyota', 'Japan', 1937, 'https://www.toyota.com', 1, 'Надёжные автомобили массового сегмента'),
('Tesla', 'USA', 2003, 'https://www.tesla.com', 1, 'Инновационные электромобили и энергетические решения'),
('Audi', 'Germany', 1909, 'https://www.audi.com', 1, 'Технологичные премиальные автомобили'),
('Volkswagen', 'Germany', 1937, 'https://www.volkswagen.com', 1, 'Автомобили для широкой аудитории'),
('Ford', 'USA', 1903, 'https://www.ford.com', 1, 'Американский автопроизводитель с богатой историей'),
('Hyundai', 'South Korea', 1967, 'https://www.hyundai.com', 1, 'Современные автомобили с отличным соотношением цены и качества'),
('Volvo', 'Sweden', 1927, 'https://www.volvo.com', 1, 'Безопасность и скандинавский дизайн'),
('Porsche', 'Germany', 1931, 'https://www.porsche.com', 1, 'Спортивные автомобили премиум-класса'),
('Lexus', 'Japan', 1989, 'https://www.lexus.com', 1, 'Премиальное подразделение Toyota'),
('Kia', 'South Korea', 1944, 'https://www.kia.com', 1, 'Динамично развивающийся корейский бренд');
GO

-- Заполнение Models
INSERT INTO Models (ModelName, ProductionStartYear, ProductionEndYear, BodyType, EngineType, Horsepower, FuelConsumption, TransmissionType, BasePrice, IsElectric, SafetyRating) VALUES
('X5', 1999, NULL, 'Внедорожник', 'Бензиновый', 340, 11.5, 'Автомат', 8500000.00, 0, 4.8),
('Camry', 1982, NULL, 'Седан', 'Бензиновый', 203, 8.6, 'Автомат', 3500000.00, 0, 4.9),
('Model S', 2012, NULL, 'Седан', 'Электрический', 670, 0, 'Автомат', 12000000.00, 1, 5.0),
('A4', 1994, NULL, 'Седан', 'Бензиновый', 249, 7.8, 'Автомат', 4200000.00, 0, 4.7),
('Golf', 1974, NULL, 'Хэтчбек', 'Бензиновый', 150, 6.4, 'Механика', 2100000.00, 0, 4.6),
('Mustang', 1964, NULL, 'Купе', 'Бензиновый', 450, 13.2, 'Автомат', 5800000.00, 0, 4.3),
('Tucson', 2004, NULL, 'Внедорожник', 'Бензиновый', 150, 8.9, 'Автомат', 2800000.00, 0, 4.5),
('XC90', 2002, NULL, 'Внедорожник', 'Гибрид', 310, 2.1, 'Автомат', 7200000.00, 0, 5.0),
('911', 1963, NULL, 'Купе', 'Бензиновый', 450, 11.1, 'Робот', 11500000.00, 0, 4.4),
('RX', 1998, NULL, 'Внедорожник', 'Гибрид', 313, 5.8, 'Автомат', 6100000.00, 0, 4.8),
('Sportage', 1993, NULL, 'Внедорожник', 'Бензиновый', 150, 9.1, 'Автомат', 2600000.00, 0, 4.4),
('Model 3', 2017, NULL, 'Седан', 'Электрический', 283, 0, 'Автомат', 5500000.00, 1, 5.0);
GO

-- Заполнение ServiceCenters
INSERT INTO ServiceCenters (CenterName, Address, PhoneNumber, Email, City, Specialization, OpenTime, CloseTime, Rating, IsOfficialDealer) VALUES
('АвтоПремиум Минск', 'пр. Независимости, 169', '+375 17 123-45-67', 'info@autopremium.by', 'Минск', 'Официальный дилер премиум-брендов', '09:00', '20:00', 4.8, 1),
('Тойота Центр Гомель', 'ул. Советская, 39', '+375 232 23-45-67', 'service@toyota-gomel.by', 'Гомель', 'Официальный дилер Toyota', '08:00', '21:00', 4.9, 1),
('ЭлектроАвто Сервис', 'ул. Немига, 25', '+375 17 345-67-89', 'ev@electroauto.by', 'Минск', 'Специализированный сервис по электромобилям', '10:00', '19:00', 4.6, 0),
('Немецкое Качество', 'пр. Дзержинского, 120', '+375 17 456-78-90', 'info@germanquality.by', 'Минск', 'Авторизованный сервис BMW, Mercedes, Audi', '09:00', '20:00', 4.7, 0),
('АвтоСити Брест', 'ул. Московская, 51', '+375 162 56-78-90', 'service@autocity-brest.by', 'Брест', 'Универсальный сервис', '09:00', '19:00', 4.3, 0),
('Корейские Авто Витебск', 'пр. Фрунзе, 82', '+375 212 67-89-01', 'info@koreanauto-vitebsk.by', 'Витебск', 'Официальный дилер Hyundai, Kia', '09:00', '20:00', 4.5, 1),
('Вольво Центр Гродно', 'ул. Горького, 141', '+375 152 78-90-12', 'service@volvo-grodno.by', 'Гродно', 'Официальный дилер Volvo', '09:00', '18:00', 4.8, 1),
('Порше Центр Минск', 'ул. Тимирязева, 11', '+375 17 890-12-34', 'info@porsche-minsk.by', 'Минск', 'Официальный дилер Porsche', '10:00', '19:00', 4.9, 1),
('АвтоМастер Могилев', 'ул. Ленинская, 176', '+375 222 90-12-34', 'service@avtomaster-mogilev.by', 'Могилев', 'Специализированный ремонт', '09:00', '18:00', 4.2, 0),
('Тесла Сервис Минск', 'пр. Победителей, 10', '+375 17 012-34-56', 'service@tesla-minsk.by', 'Минск', 'Официальный сервисный центр Tesla', '09:00', '21:00', 4.9, 1),
('Форд Центр Бобруйск', 'ул. Социалистическая, 32', '+375 241 12-34-56', 'info@ford-bobruisk.by', 'Бобруйск', 'Официальный дилер Ford', '09:00', '20:00', 4.6, 1),
('АвтоЭксперт Орша', 'ул. Ленина, 45', '+375 216 23-45-67', 'service@autoexpert-orsha.by', 'Орша', 'Универсальный сервис', '09:00', '19:00', 4.4, 0);
GO

-- Заполнение Customers
INSERT INTO Customers (CustomerFirstName, CustomerSecondName, Email, PhoneNumber, City, RegistrationDate, LoyaltyLevel) VALUES
('Іван', 'Петраў', 'ivan.petrou@email.by', '+375 29 111-22-33', 'Мінск', '2023-01-15', 'Gold'),
('Марыя', 'Сідарова', 'maria.sidorava@email.by', '+375 29 222-33-44', 'Гомель', '2023-02-20', 'Silver'),
('Аляксей', 'Казлоў', 'alexey.kazlou@email.by', '+375 29 333-44-55', 'Мінск', '2023-03-10', 'Platinum'),
('Алена', 'Навікава', 'elena.navikava@email.by', '+375 29 444-55-66', 'Брэст', '2023-04-05', 'Bronze'),
('Дзмітрый', 'Сокалаў', 'dmitry.sokalau@email.by', '+375 29 555-66-77', 'Віцебск', '2023-05-12', 'Silver'),
('Ганна', 'Маразова', 'anna.marazava@email.by', '+375 29 666-77-88', 'Гродна', '2023-06-18', 'Gold'),
('Сяргей', 'Воўкаў', 'sergey.volkau@email.by', '+375 29 777-88-99', 'Магілёў', '2023-07-22', 'Bronze'),
('Вольга', 'Лебедзева', 'volga.lebedzeva@email.by', '+375 29 888-99-00', 'Мінск', '2023-08-30', 'Platinum'),
('Міхаіл', 'Паўлаў', 'mikhail.paulau@email.by', '+375 29 999-00-11', 'Бабруйск', '2023-09-14', 'Silver'),
('Таццяна', 'Ягорава', 'tatyana.yegorava@email.by', '+375 29 000-11-22', 'Орша', '2023-10-25', 'Gold'),
('Андрэй', 'Грыгор\'еў', 'andrey.grigoryeu@email.by', '+375 29 111-22-33', 'Пінск', '2023-11-08', 'Bronze'),
('Наталля', 'Раманава', 'natalya.ramanava@email.by', '+375 29 222-33-44', 'Мінск', '2023-12-01', 'Silver');
GO

--Заполнение таблиц рёбер

-- Заполнение BELONGS_TO: связь Моделей с Марками
MERGE BELONGS_TO AS target
USING (
    SELECT 
        m.$node_id AS from_id,
        b.$node_id AS to_id,
        CASE 
            WHEN m.ModelName = 'X5' THEN '1999-01-01'
            WHEN m.ModelName = 'Camry' THEN '1982-01-01'
            WHEN m.ModelName = 'Model S' THEN '2012-01-01'
            WHEN m.ModelName = 'A4' THEN '1994-01-01'
            WHEN m.ModelName = 'Golf' THEN '1974-01-01'
            WHEN m.ModelName = 'Mustang' THEN '1964-01-01'
            WHEN m.ModelName = 'Tucson' THEN '2004-01-01'
            WHEN m.ModelName = 'XC90' THEN '2002-01-01'
            WHEN m.ModelName = '911' THEN '1963-01-01'
            WHEN m.ModelName = 'RX' THEN '1998-01-01'
            WHEN m.ModelName = 'Sportage' THEN '1993-01-01'
            WHEN m.ModelName = 'Model 3' THEN '2017-01-01'
        END AS StartDate
    FROM Models m
    INNER JOIN Brands b ON 
        (m.ModelName = 'X5' AND b.BrandName = 'BMW') OR
        (m.ModelName = 'Camry' AND b.BrandName = 'Toyota') OR
        (m.ModelName = 'Model S' AND b.BrandName = 'Tesla') OR
        (m.ModelName = 'A4' AND b.BrandName = 'Audi') OR
        (m.ModelName = 'Golf' AND b.BrandName = 'Volkswagen') OR
        (m.ModelName = 'Mustang' AND b.BrandName = 'Ford') OR
        (m.ModelName = 'Tucson' AND b.BrandName = 'Hyundai') OR
        (m.ModelName = 'XC90' AND b.BrandName = 'Volvo') OR
        (m.ModelName = '911' AND b.BrandName = 'Porsche') OR
        (m.ModelName = 'RX' AND b.BrandName = 'Lexus') OR
        (m.ModelName = 'Sportage' AND b.BrandName = 'Kia') OR
        (m.ModelName = 'Model 3' AND b.BrandName = 'Tesla')
) AS source
ON target.$from_id = source.from_id AND target.$to_id = source.to_id
WHEN NOT MATCHED THEN
    INSERT ($from_id, $to_id, StartDate, IsCurrentModel)
    VALUES (source.from_id, source.to_id, source.StartDate, 1);
GO

-- Заполнение SERVES: связь Сервисных центров с Марками
MERGE SERVES AS target
USING (
    SELECT 
        sc.$node_id AS from_id,
        b.$node_id AS to_id,
        CASE 
            WHEN sc.CenterName = 'АвтоПремиум Москва' AND b.BrandName IN ('BMW', 'Mercedes-Benz', 'Audi', 'Porsche') THEN 'Официальный дилер'
            WHEN sc.CenterName = 'Тойота Центр СПб' AND b.BrandName = 'Toyota' THEN 'Официальный дилер'
            WHEN sc.CenterName = 'ЭлектроАвто Сервис' AND b.BrandName = 'Tesla' THEN 'Специализированный ремонт'
            WHEN sc.CenterName = 'Немецкое Качество' AND b.BrandName IN ('BMW', 'Mercedes-Benz', 'Audi') THEN 'Авторизованный сервис'
            WHEN sc.CenterName = 'Корейские Авто Новосибирск' AND b.BrandName IN ('Hyundai', 'Kia') THEN 'Официальный дилер'
            WHEN sc.CenterName = 'Вольво Центр Казань' AND b.BrandName = 'Volvo' THEN 'Официальный дилер'
            WHEN sc.CenterName = 'Порше Центр Сочи' AND b.BrandName = 'Porsche' THEN 'Официальный дилер'
            WHEN sc.CenterName = 'Тесла Сервис Москва' AND b.BrandName = 'Tesla' THEN 'Официальный дилер'
            WHEN sc.CenterName = 'Форд Центр Ростов' AND b.BrandName = 'Ford' THEN 'Официальный дилер'
            ELSE 'Универсальный'
        END AS SpecializationLevel,
        '2023-01-01' AS ContractStartDate
    FROM ServiceCenters sc
    INNER JOIN Brands b ON
        (sc.CenterName = 'АвтоПремиум Москва' AND b.BrandName IN ('BMW', 'Mercedes-Benz', 'Audi', 'Porsche')) OR
        (sc.CenterName = 'Тойота Центр СПб' AND b.BrandName = 'Toyota') OR
        (sc.CenterName = 'ЭлектроАвто Сервис' AND b.BrandName = 'Tesla') OR
        (sc.CenterName = 'Немецкое Качество' AND b.BrandName IN ('BMW', 'Mercedes-Benz', 'Audi')) OR
        (sc.CenterName = 'Корейские Авто Новосибирск' AND b.BrandName IN ('Hyundai', 'Kia')) OR
        (sc.CenterName = 'Вольво Центр Казань' AND b.BrandName = 'Volvo') OR
        (sc.CenterName = 'Порше Центр Сочи' AND b.BrandName = 'Porsche') OR
        (sc.CenterName = 'Тесла Сервис Москва' AND b.BrandName = 'Tesla') OR
        (sc.CenterName = 'Форд Центр Ростов' AND b.BrandName = 'Ford') OR
        (sc.CenterName = 'АвтоСити Екатеринбург') OR
        (sc.CenterName = 'АвтоМастер Краснодар') OR
        (sc.CenterName = 'АвтоЭксперт Воронеж')
) AS source
ON target.$from_id = source.from_id AND target.$to_id = source.to_id
WHEN NOT MATCHED THEN
    INSERT ($from_id, $to_id, SpecializationLevel, ContractStartDate, ServiceQualityRating)
    VALUES (source.from_id, source.to_id, source.SpecializationLevel, source.ContractStartDate, 
            CASE WHEN source.SpecializationLevel = 'Официальный дилер' THEN 4.8 ELSE 4.3 END);
GO

-- Заполнение PURCHASED_BY: связь Клиентов с Моделями
MERGE PURCHASED_BY AS target
USING (
    SELECT 
        c.$node_id AS from_id,
        m.$node_id AS to_id,
        CASE 
            WHEN c.CustomerFirstName = 'Іван' AND c.CustomerSecondName = 'Петраў' AND m.ModelName = 'X5' THEN '2024-03-15'
            WHEN c.CustomerFirstName = 'Марыя' AND c.CustomerSecondName = 'Сідарова' AND m.ModelName = 'Camry' THEN '2024-02-20'
            WHEN c.CustomerFirstName = 'Аляксей' AND c.CustomerSecondName = 'Казлоў' AND m.ModelName = 'Model S' THEN '2024-04-10'
            WHEN c.CustomerFirstName = 'Алена' AND c.CustomerSecondName = 'Навікава' AND m.ModelName = 'Tucson' THEN '2024-01-25'
            WHEN c.CustomerFirstName = 'Дзмітрый' AND c.CustomerSecondName = 'Сокалаў' AND m.ModelName = 'Sportage' THEN '2024-05-12'
            WHEN c.CustomerFirstName = 'Ганна' AND c.CustomerSecondName = 'Маразова' AND m.ModelName = 'XC90' THEN '2024-03-18'
            WHEN c.CustomerFirstName = 'Сяргей' AND c.CustomerSecondName = 'Воўкаў' AND m.ModelName = '911' THEN '2024-06-22'
            WHEN c.CustomerFirstName = 'Вольга' AND c.CustomerSecondName = 'Лебедзева' AND m.ModelName = 'RX' THEN '2024-04-30'
            WHEN c.CustomerFirstName = 'Міхаіл' AND c.CustomerSecondName = 'Паўлаў' AND m.ModelName = 'Mustang' THEN '2024-02-14'
            WHEN c.CustomerFirstName = 'Таццяна' AND c.CustomerSecondName = 'Ягорава' AND m.ModelName = 'Model 3' THEN '2024-05-25'
            WHEN c.CustomerFirstName = 'Андрэй' AND c.CustomerSecondName = 'Грыгор\'еў' AND m.ModelName = 'Golf' THEN '2024-03-08'
            WHEN c.CustomerFirstName = 'Наталля' AND c.CustomerSecondName = 'Раманава' AND m.ModelName = 'A4' THEN '2024-06-01'
        END AS PurchaseDate,
        CASE 
            WHEN m.ModelName = 'X5' THEN 8500000.00
            WHEN m.ModelName = 'Camry' THEN 3500000.00
            WHEN m.ModelName = 'Model S' THEN 12000000.00
            WHEN m.ModelName = 'Tucson' THEN 2800000.00
            WHEN m.ModelName = 'Sportage' THEN 2600000.00
            WHEN m.ModelName = 'XC90' THEN 7200000.00
            WHEN m.ModelName = '911' THEN 11500000.00
            WHEN m.ModelName = 'RX' THEN 6100000.00
            WHEN m.ModelName = 'Mustang' THEN 5800000.00
            WHEN m.ModelName = 'Model 3' THEN 5500000.00
            WHEN m.ModelName = 'Golf' THEN 2100000.00
            WHEN m.ModelName = 'A4' THEN 4200000.00
        END AS PurchasePrice
    FROM Customers c
    INNER JOIN Models m ON
        (c.CustomerFirstName = 'Іван' AND c.CustomerSecondName = 'Петраў' AND m.ModelName = 'X5') OR
        (c.CustomerFirstName = 'Марыя' AND c.CustomerSecondName = 'Сідарова' AND m.ModelName = 'Camry') OR
        (c.CustomerFirstName = 'Аляксей' AND c.CustomerSecondName = 'Казлоў' AND m.ModelName = 'Model S') OR
        (c.CustomerFirstName = 'Алена' AND c.CustomerSecondName = 'Навікава' AND m.ModelName = 'Tucson') OR
        (c.CustomerFirstName = 'Дзмітрый' AND c.CustomerSecondName = 'Сокалаў' AND m.ModelName = 'Sportage') OR
        (c.CustomerFirstName = 'Ганна' AND c.CustomerSecondName = 'Маразова' AND m.ModelName = 'XC90') OR
        (c.CustomerFirstName = 'Сяргей' AND c.CustomerSecondName = 'Воўкаў' AND m.ModelName = '911') OR
        (c.CustomerFirstName = 'Вольга' AND c.CustomerSecondName = 'Лебедзева' AND m.ModelName = 'RX') OR
        (c.CustomerFirstName = 'Міхаіл' AND c.CustomerSecondName = 'Паўлаў' AND m.ModelName = 'Mustang') OR
        (c.CustomerFirstName = 'Таццяна' AND c.CustomerSecondName = 'Ягорава' AND m.ModelName = 'Model 3') OR
        (c.CustomerFirstName = 'Андрэй' AND c.CustomerSecondName = 'Грыгор\'еў' AND m.ModelName = 'Golf') OR
        (c.CustomerFirstName = 'Наталля' AND c.CustomerSecondName = 'Раманава' AND m.ModelName = 'A4')
) AS source
ON target.$from_id = source.from_id AND target.$to_id = source.to_id
WHEN NOT MATCHED THEN
    INSERT ($from_id, $to_id, PurchaseDate, PurchasePrice, PaymentMethod, WarrantyYears)
    VALUES (source.from_id, source.to_id, source.PurchaseDate, source.PurchasePrice, 'Банковская карта', 3);
GO

--Запросы с функцией MATCH

-- ЗАПРОС 1: Найти самые старые модели у каждой марки
-- Цепочка: Brands <- BELONGS_TO - Models
SELECT 
    B.BrandName AS [Марка],
    M.ModelName AS [Самая старая модель],
    M.ProductionStartYear AS [Год начала выпуска]
FROM Brands B, Models M, BELONGS_TO BT
WHERE MATCH(B<-(BT)-M)
GROUP BY B.BrandName, M.ModelName, M.ProductionStartYear
HAVING M.ProductionStartYear = MIN(M.ProductionStartYear) OVER (PARTITION BY B.BrandName)
ORDER BY M.ProductionStartYear;
GO

-- ЗАПРОС 2: Найти клиентов, купивших модели всех марок
-- Цепочка: Customers -> PURCHASED_BY -> Models <- BELONGS_TO - Brands
SELECT 
    CONCAT(C.CustomerFirstName, ' ', C.CustomerSecondName) AS [Клиент],
    COUNT(DISTINCT B.BrandName) AS [Количество купленных марок]
FROM Customers C, PURCHASED_BY PB, Models M, BELONGS_TO BT, Brands B
WHERE MATCH(C-(PB)->M<-(BT)-B)
GROUP BY C.CustomerFirstName, C.CustomerSecondName
HAVING COUNT(DISTINCT B.BrandName) = (SELECT COUNT(*) FROM Brands)
ORDER BY [Количество купленных марок] DESC;
GO

-- ЗАПРОС 3: Анализ популярности типов двигателей среди проданных авто
-- Цепочка: Customers -> PURCHASED_BY -> Models
SELECT 
    M.EngineType AS [Тип двигателя],
    COUNT(*) AS [Количество покупок],
    AVG(M.BasePrice) AS [Средняя цена],
    STRING_AGG(DISTINCT B.BrandName, ', ') AS [Бренды]
FROM Customers C, PURCHASED_BY PB, Models M, BELONGS_TO BT, Brands B
WHERE MATCH(C-(PB)->M<-(BT)-B)
GROUP BY M.EngineType
ORDER BY [Количество покупок] DESC;
GO

-- ЗАПРОС 4: Найти модели, которые может обслужить сервисный центр 
-- в том же городе, где живёт клиент, купивший эту модель
-- Цепочка: Customers -> PURCHASED_BY -> Models <- BELONGS_TO - Brands <- SERVES - ServiceCenters
SELECT DISTINCT
    M.ModelName AS [Модель],
    B.BrandName AS [Марка],
    CONCAT(C.CustomerFirstName, ' ', C.CustomerSecondName) AS [Клиент],
    C.City AS [Город клиента],
    SC.CenterName AS [Сервисный центр],
    SC.Specialization AS [Специализация сервиса]
FROM Customers C, PURCHASED_BY PB, Models M, BELONGS_TO BT, Brands B, SERVES SB, ServiceCenters SC
WHERE MATCH(C-(PB)->M<-(BT)-B<-(SB)-SC)
    AND C.City = SC.City
ORDER BY C.City, B.BrandName;
GO

-- ЗАПРОС 5: Найти марки, не имеющие официальных дилеров в городах с клиентами
-- Цепочка: Customers -> PURCHASED_BY -> Models <- BELONGS_TO - Brands
-- с проверкой отсутствия связи через сервисные центры
SELECT DISTINCT
    B.BrandName AS [Марка без покрытия],
    B.CountryOfOrigin AS [Страна],
    C.City AS [Город с клиентами],
    COUNT(DISTINCT C.CustomerID) AS [Количество клиентов в городе]
FROM Brands B, Models M, BELONGS_TO BT, PURCHASED_BY PB, Customers C
WHERE MATCH(B<-(BT)-M<-(PB)-C)
    AND NOT EXISTS (
        SELECT 1
        FROM ServiceCenters SC, SERVES SB
        WHERE MATCH(SC-(SB)->B)
            AND SC.City = C.City
            AND SB.SpecializationLevel = 'Официальный дилер'
    )
GROUP BY B.BrandName, B.CountryOfOrigin, C.City
ORDER BY [Количество клиентов в городе] DESC;
GO

--Запросы с функцией SHORTEST_PATH

-- ЗАПРОС 1: Найти кратчайший путь от клиента к бренду через покупки
-- Использование шаблона "+" (один или более шагов)
-- Требуется: LAST_NODE, STRING_AGG, FOR PATH
SELECT 
    CONCAT(C.CustomerFirstName, ' ', C.CustomerSecondName) AS [Клиент],
    STRING_AGG(NodeName.value('(/n/text())[1]', 'NVARCHAR(100)'), ' -> ') WITHIN GROUP (GRAPH PATH) AS [Путь],
    LAST_VALUE(M.ModelName) WITHIN GROUP (GRAPH PATH) AS [Купленная модель],
    LAST_VALUE(B.BrandName) WITHIN GROUP (GRAPH PATH) AS [Бренд]
FROM 
    Customers C,
    Models M FOR PATH,
    Brands B FOR PATH,
    PURCHASED_BY PB FOR PATH,
    BELONGS_TO BT FOR PATH
WHERE 
    MATCH(SHORTEST_PATH(C(-(PB)->M)+(-(BT)->B)))
    AND C.CustomerFirstName = 'Иван' AND C.CustomerSecondName = 'Петров'
GROUP BY C.CustomerFirstName, C.CustomerSecondName, LAST_NODE(M).ModelName, LAST_NODE(B).BrandName;
GO

-- ЗАПРОС 2: Найти все марки, доступные через сервисные центры 
-- на расстоянии от 1 до 3 шагов от клиента
-- Использование шаблона "{1,3}"
SELECT 
    CONCAT(C.CustomerFirstName, ' ', C.CustomerSecondName) AS [Клиент],
    C.City AS [Город],
    STRING_AGG(NodeName.value('(/n/text())[1]', 'NVARCHAR(100)'), ' => ') WITHIN GROUP (GRAPH PATH) AS [Цепочка доступа],
    LAST_VALUE(SC.CenterName) WITHIN GROUP (GRAPH PATH) AS [Сервисный центр],
    LAST_VALUE(B.BrandName) WITHIN GROUP (GRAPH PATH) AS [Доступная марка],
    LAST_VALUE(SB.SpecializationLevel) WITHIN GROUP (GRAPH PATH) AS [Тип сервиса]
FROM 
    Customers C,
    ServiceCenters SC FOR PATH,
    Brands B FOR PATH,
    PURCHASED_BY PB FOR PATH,
    Models M FOR PATH,
    BELONGS_TO BT FOR PATH,
    SERVES SB FOR PATH
WHERE 
    MATCH(SHORTEST_PATH(C(-(PB)->M<-(BT)-B<-(SB)-SC){1,3}))
    AND C.City = SC.City
GROUP BY 
    C.CustomerFirstName,
    C.CustomerSecondName, 
    C.City,
    LAST_NODE(SC).CenterName,
    LAST_NODE(B).BrandName,
    LAST_NODE(SB).SpecializationLevel
ORDER BY CONCAT(C.CustomerFirstName, ' ', C.CustomerSecondName), [Доступная марка];
GO
