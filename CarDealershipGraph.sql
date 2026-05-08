--Создание базы данных

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = N'CarDealershipGraph')
BEGIN
    ALTER DATABASE CarDealershipGraph SET single_user WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CarDealershipGraph;
END

CREATE DATABASE CarDealershipGraph;
GO

USE CarDealershipGraph;
GO

-- СОЗДАНИЕ ТАБЛИЦ УЗЛОВ

-- УЗЕЛ 1: Brands (Марки автомобилей)
CREATE TABLE Brands (
    BrandID INT NOT NULL PRIMARY KEY,
    BrandName NVARCHAR(100) NOT NULL UNIQUE,
    CountryOfOrigin NVARCHAR(100),
    YearFounded SMALLINT,
    Website NVARCHAR(500),
    IsManufacturerActive BIT DEFAULT 1,
    Description NVARCHAR(500)
) AS NODE;
GO

-- УЗЕЛ 2: Models (Модели автомобилей)
CREATE TABLE Models (
    ModelID INT NOT NULL PRIMARY KEY,
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

-- УЗЕЛ 3: ServiceCenters (Сервисные центры)
CREATE TABLE ServiceCenters (
    CenterID INT NOT NULL PRIMARY KEY,
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

-- УЗЕЛ 4: Customers (Клиенты)
CREATE TABLE Customers (
    CustomerID INT NOT NULL PRIMARY KEY,
    CustomerFirstName NVARCHAR(100) NOT NULL,
    CustomerSecondName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    City NVARCHAR(100),
    RegistrationDate DATE DEFAULT GETDATE(),
    LoyaltyLevel NVARCHAR(50) CHECK (LoyaltyLevel IN (N'Bronze',N'Silver',N'Gold',N'Platinum'))
) AS NODE;
GO

-- СОЗДАНИЕ ТАБЛИЦ РЁБЕР

-- РЕБРО 1: BELONGS_TO (Model -> Brand)
CREATE TABLE BELONGS_TO (
    StartDate DATE,
    EndDate DATE,
    IsCurrentModel BIT DEFAULT 1
) AS EDGE;
GO

ALTER TABLE BELONGS_TO 
ADD CONSTRAINT EC_BELONGS_TO 
CONNECTION (Models TO Brands) ON DELETE NO ACTION;
GO

-- РЕБРО 2: SERVES (ServiceCenter -> Brand)
CREATE TABLE SERVES (
    SpecializationLevel NVARCHAR(50) 
        CHECK (SpecializationLevel IN (N'Официальный дилер', N'Авторизованный сервис', N'Специализированный ремонт', N'Универсальный')),
    ContractStartDate DATE,
    ContractEndDate DATE,
    ServiceQualityRating DECIMAL(3,2)
) AS EDGE;
GO

ALTER TABLE SERVES 
ADD CONSTRAINT EC_SERVES 
CONNECTION (ServiceCenters TO Brands) ON DELETE NO ACTION;
GO

-- РЕБРО 3: PURCHASES (Customer -> Model)
CREATE TABLE PURCHASES (
    PurchaseDate DATE NOT NULL DEFAULT GETDATE(),
    PurchasePrice DECIMAL(12,2),
    PaymentMethod NVARCHAR(50) CHECK (PaymentMethod IN (N'Наличные', N'Банковская карта')),
    WarrantyYears INT,
    IsTradeIn BIT DEFAULT 0
) AS EDGE;
GO

ALTER TABLE PURCHASES 
ADD CONSTRAINT EC_PURCHASES 
CONNECTION (Customers TO Models) ON DELETE NO ACTION;
GO

-- ЗАПОЛНЕНИЕ ТАБЛИЦ УЗЛОВ

-- 1. Brands (12 марок)
INSERT INTO Brands (BrandID, BrandName, CountryOfOrigin, YearFounded, Website, IsManufacturerActive, Description) VALUES
(1,  N'BMW',           N'Germany',      1916, N'https://www.bmw.com',            1, N'Премиальные автомобили с акцентом на динамику'),
(2,  N'Mercedes-Benz', N'Germany',      1926, N'https://www.mercedes-benz.com',  1, N'Роскошные автомобили и коммерческий транспорт'),
(3,  N'Toyota',        N'Japan',        1937, N'https://www.toyota.com',         1, N'Надёжные автомобили массового сегмента'),
(4,  N'Tesla',         N'USA',          2003, N'https://www.tesla.com',          1, N'Инновационные электромобили и энергетические решения'),
(5,  N'Audi',          N'Germany',      1909, N'https://www.audi.com',           1, N'Технологичные премиальные автомобили'),
(6,  N'Volkswagen',    N'Germany',      1937, N'https://www.volkswagen.com',     1, N'Автомобили для широкой аудитории'),
(7,  N'Ford',          N'USA',          1903, N'https://www.ford.com',           1, N'Американский автопроизводитель с богатой историей'),
(8,  N'Hyundai',       N'South Korea',  1967, N'https://www.hyundai.com',        1, N'Современные автомобили с отличным соотношением цены и качества'),
(9,  N'Volvo',         N'Sweden',       1927, N'https://www.volvo.com',          1, N'Безопасность и скандинавский дизайн'),
(10, N'Porsche',       N'Germany',      1931, N'https://www.porsche.com',        1, N'Спортивные автомобили премиум-класса'),
(11, N'Lexus',         N'Japan',        1989, N'https://www.lexus.com',          1, N'Премиальное подразделение Toyota'),
(12, N'Kia',           N'South Korea',  1944, N'https://www.kia.com',            1, N'Динамично развивающийся корейский бренд');
GO

SELECT * FROM Brands

-- 2. Models (12 моделей)
INSERT INTO Models (ModelID, ModelName, ProductionStartYear, ProductionEndYear, BodyType, EngineType, Horsepower, FuelConsumption, TransmissionType, BasePrice, IsElectric, SafetyRating) VALUES
(1,  N'X5',       1999, NULL, N'Внедорожник', N'Бензиновый', 340, 11.5, N'Автомат', 8500000.00, 0, 4.8),
(2,  N'Camry',    1982, NULL, N'Седан',       N'Бензиновый', 203,  8.6, N'Автомат', 3500000.00, 0, 4.9),
(3,  N'Model S',  2012, NULL, N'Седан',       N'Электрический', 670, 0, N'Автомат', 12000000.00, 1, 5.0),
(4,  N'A4',       1994, NULL, N'Седан',       N'Бензиновый', 249,  7.8, N'Автомат', 4200000.00, 0, 4.7),
(5,  N'Golf',     1974, NULL, N'Хэтчбек',     N'Бензиновый', 150,  6.4, N'Механика', 2100000.00, 0, 4.6),
(6,  N'Mustang',  1964, NULL, N'Купе',        N'Бензиновый', 450, 13.2, N'Автомат', 5800000.00, 0, 4.3),
(7,  N'Tucson',   2004, NULL, N'Внедорожник', N'Бензиновый', 150,  8.9, N'Автомат', 2800000.00, 0, 4.5),
(8,  N'XC90',     2002, NULL, N'Внедорожник', N'Гибрид',     310,  2.1, N'Автомат', 7200000.00, 0, 5.0),
(9,  N'911',      1963, NULL, N'Купе',        N'Бензиновый', 450, 11.1, N'Робот', 11500000.00, 0, 4.4),
(10, N'RX',       1998, NULL, N'Внедорожник', N'Гибрид',     313,  5.8, N'Автомат', 6100000.00, 0, 4.8),
(11, N'Sportage', 1993, NULL, N'Внедорожник', N'Бензиновый', 150,  9.1, N'Автомат', 2600000.00, 0, 4.4),
(12, N'Model 3',  2017, NULL, N'Седан',       N'Электрический', 283, 0, N'Автомат', 5500000.00, 1, 5.0);
GO

SELECT * FROM Models

-- 3. ServiceCenters (12 центров)
INSERT INTO ServiceCenters (CenterID, CenterName, Address, PhoneNumber, Email, City, Specialization, OpenTime, CloseTime, Rating, IsOfficialDealer) VALUES
(1,  N'АвтоПремиум Минск',    N'пр-т Независимости, 95', N'+375 17 234-56-78', N'info@autopremium.by',      N'Минск',     N'Официальный дилер премиум-брендов',    N'09:00', N'20:00', 4.8, 1),
(2,  N'Тойота Центр Гомель',  N'ул. Советская, 120',     N'+375 232 45-67-89', N'service@toyota-gomel.by',  N'Гомель',    N'Официальный дилер Toyota',             N'08:00', N'21:00', 4.9, 1),
(3,  N'ЭлектроАвто Сервис',   N'ул. Новая, 25',          N'+375 17 345-67-89', N'ev@electroauto.by',        N'Минск',     N'Специализированный сервис по электромобилям', N'10:00', N'19:00', 4.6, 0),
(4,  N'Немецкое Качество',    N'пр-т Победителей, 120',  N'+375 17 456-78-90', N'info@germanquality.by',    N'Минск',     N'Авторизованный сервис BMW, Mercedes, Audi', N'09:00', N'20:00', 4.7, 0),
(5,  N'АвтоСити Брест',       N'ул. Московская, 51',     N'+375 162 56-78-90', N'service@autocity-brest.by',N'Брест',     N'Универсальный сервис',                  N'09:00', N'19:00', 4.3, 0),
(6,  N'Корейские Авто Витебск',N'пр-т Фрунзе, 82',       N'+375 212 67-89-01', N'info@koreanauto-vitebsk.by',N'Витебск',  N'Официальный дилер Hyundai, Kia',       N'09:00', N'20:00', 4.5, 1),
(7,  N'Вольво Центр Гродно',  N'ул. Горького, 141',      N'+375 152 78-90-12', N'service@volvo-grodno.by',  N'Гродно',    N'Официальный дилер Volvo',              N'09:00', N'18:00', 4.8, 1),
(8,  N'Порше Центр Минск',    N'ул. Немига, 11',         N'+375 17 890-12-34', N'info@porsche-minsk.by',    N'Минск',     N'Официальный дилер Porsche',            N'10:00', N'19:00', 4.9, 1),
(9,  N'АвтоМастер Могилев',   N'ул. Ленинская, 176',     N'+375 222 90-12-34', N'service@avtomaster-mogilev.by', N'Могилев', N'Специализированный ремонт',           N'09:00', N'18:00', 4.2, 0),
(10, N'Тесла Сервис Минск',   N'ул. Тимирязева, 10',     N'+375 17 012-34-56', N'service@tesla-minsk.by',   N'Минск',     N'Официальный сервисный центр Tesla',   N'09:00', N'21:00', 4.9, 1),
(11, N'Форд Центр Бобруйск',  N'ул. Социалистическая, 32',N'+375 241 12-34-56', N'info@ford-bobruisk.by',    N'Бобруйск',  N'Официальный дилер Ford',               N'09:00', N'20:00', 4.6, 1),
(12, N'АвтоЭксперт Барановичи',N'ул. Советская, 45',      N'+375 163 23-45-67', N'service@autoexpert-baranovichi.by', N'Барановичи', N'Универсальный сервис',           N'09:00', N'19:00', 4.4, 0);
GO

SELECT * FROM ServiceCenters

-- 4. Customers (12 клиентов)
INSERT INTO Customers (CustomerID, CustomerFirstName, CustomerSecondName, Email, PhoneNumber, City, RegistrationDate, LoyaltyLevel) VALUES
(1,  N'Иван',    N'Петров',    N'ivan.petrov@gmail.com',     N'+375 29 111-22-33', N'Минск',       '2023-01-15', N'Gold'),
(2,  N'Мария',   N'Сидорова',  N'maria.sidorova@gmail.com',  N'+375 29 222-33-44', N'Гомель',      '2023-02-20', N'Silver'),
(3,  N'Алексей', N'Козлов',    N'alexey.kozlov@gmail.com',   N'+375 29 333-44-55', N'Минск',       '2023-03-10', N'Platinum'),
(4,  N'Елена',   N'Новикова',  N'elena.novikova@gmail.com',  N'+375 29 444-55-66', N'Брест',       '2023-04-05', N'Bronze'),
(5,  N'Дмитрий', N'Соколов',   N'dmitry.sokolov@gmail.com',  N'+375 29 555-66-77', N'Витебск',     '2023-05-12', N'Silver'),
(6,  N'Анна',    N'Морозова',  N'anna.morozova@gmail.com',   N'+375 29 666-77-88', N'Гродно',      '2023-06-18', N'Gold'),
(7,  N'Сергей',  N'Волков',    N'sergey.volkov@gmail.com',   N'+375 29 777-88-99', N'Могилев',     '2023-07-22', N'Bronze'),
(8,  N'Ольга',   N'Лебедева',  N'olga.lebedeva@gmail.com',   N'+375 29 888-99-00', N'Минск',       '2023-08-30', N'Platinum'),
(9,  N'Михаил',  N'Павлов',    N'mikhail.pavlov@gmail.com',  N'+375 29 999-00-11', N'Бобруйск',    '2023-09-14', N'Silver'),
(10, N'Татьяна', N'Егорова',   N'tatyana.egorova@gmail.com', N'+375 29 000-11-22', N'Барановичи',  '2023-10-25', N'Gold'),
(11, N'Андрей',  N'Григорьев', N'andrey.grigoriev@gmail.com',N'+375 29 111-22-33', N'Пинск',       '2023-11-08', N'Bronze'),
(12, N'Наталья', N'Романова',  N'natalya.romanova@gmail.com',N'+375 29 222-33-44', N'Минск',       '2023-12-01', N'Silver');
GO

SELECT * FROM Customers

-- ЗАПОЛНЕНИЕ ТАБЛИЦ РЁБЕР

-- 1. BELONGS_TO: Model -> Brand
INSERT INTO BELONGS_TO ($from_id, $to_id, StartDate, IsCurrentModel)
VALUES
    -- X5 -> BMW
    ((SELECT $node_id FROM Models WHERE ModelID = 1),  (SELECT $node_id FROM Brands WHERE BrandID = 1),  '1999-01-01', 1),
    -- Camry -> Toyota
    ((SELECT $node_id FROM Models WHERE ModelID = 2),  (SELECT $node_id FROM Brands WHERE BrandID = 3),  '1982-01-01', 1),
    -- Model S -> Tesla
    ((SELECT $node_id FROM Models WHERE ModelID = 3),  (SELECT $node_id FROM Brands WHERE BrandID = 4),  '2012-01-01', 1),
    -- A4 -> Audi
    ((SELECT $node_id FROM Models WHERE ModelID = 4),  (SELECT $node_id FROM Brands WHERE BrandID = 5),  '1994-01-01', 1),
    -- Golf -> Volkswagen
    ((SELECT $node_id FROM Models WHERE ModelID = 5),  (SELECT $node_id FROM Brands WHERE BrandID = 6),  '1974-01-01', 1),
    -- Mustang -> Ford
    ((SELECT $node_id FROM Models WHERE ModelID = 6),  (SELECT $node_id FROM Brands WHERE BrandID = 7),  '1964-01-01', 1),
    -- Tucson -> Hyundai
    ((SELECT $node_id FROM Models WHERE ModelID = 7),  (SELECT $node_id FROM Brands WHERE BrandID = 8),  '2004-01-01', 1),
    -- XC90 -> Volvo
    ((SELECT $node_id FROM Models WHERE ModelID = 8),  (SELECT $node_id FROM Brands WHERE BrandID = 9),  '2002-01-01', 1),
    -- 911 -> Porsche
    ((SELECT $node_id FROM Models WHERE ModelID = 9),  (SELECT $node_id FROM Brands WHERE BrandID = 10), '1963-01-01', 1),
    -- RX -> Lexus
    ((SELECT $node_id FROM Models WHERE ModelID = 10), (SELECT $node_id FROM Brands WHERE BrandID = 11), '1998-01-01', 1),
    -- Sportage -> Kia
    ((SELECT $node_id FROM Models WHERE ModelID = 11), (SELECT $node_id FROM Brands WHERE BrandID = 12), '1993-01-01', 1),
    -- Model 3 -> Tesla
    ((SELECT $node_id FROM Models WHERE ModelID = 12), (SELECT $node_id FROM Brands WHERE BrandID = 4),  '2017-01-01', 1);
GO

SELECT * FROM BELONGS_TO

-- 2. SERVES: ServiceCenter -> Brand

INSERT INTO SERVES ($from_id, $to_id, SpecializationLevel, ContractStartDate, ServiceQualityRating)
VALUES
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 3), (SELECT $node_id FROM Brands WHERE BrandID = 4),  N'Специализированный ремонт', '2023-01-01', 4.6),
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 3), (SELECT $node_id FROM Brands WHERE BrandID = 5),  N'Специализированный ремонт', '2023-01-01', 4.6),
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 10), (SELECT $node_id FROM Brands WHERE BrandID = 4), N'Официальный дилер', '2023-01-01', 4.9),
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 10), (SELECT $node_id FROM Brands WHERE BrandID = 5), N'Официальный дилер', '2023-01-01', 4.9),
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 4), (SELECT $node_id FROM Brands WHERE BrandID = 5),  N'Авторизованный сервис', '2023-01-01', 4.7), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 4), (SELECT $node_id FROM Brands WHERE BrandID = 2),  N'Авторизованный сервис', '2023-01-01', 4.7), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 1), (SELECT $node_id FROM Brands WHERE BrandID = 2),  N'Официальный дилер', '2023-01-01', 4.8), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 1), (SELECT $node_id FROM Brands WHERE BrandID = 1),  N'Официальный дилер', '2023-01-01', 4.8), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 2), (SELECT $node_id FROM Brands WHERE BrandID = 3),  N'Официальный дилер', '2023-01-01', 4.9), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 6), (SELECT $node_id FROM Brands WHERE BrandID = 8),  N'Официальный дилер', '2023-01-01', 4.5), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 6), (SELECT $node_id FROM Brands WHERE BrandID = 12), N'Официальный дилер', '2023-01-01', 4.5), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 7), (SELECT $node_id FROM Brands WHERE BrandID = 9),  N'Официальный дилер', '2023-01-01', 4.8), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 11), (SELECT $node_id FROM Brands WHERE BrandID = 7), N'Официальный дилер', '2023-01-01', 4.6), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 8), (SELECT $node_id FROM Brands WHERE BrandID = 10), N'Официальный дилер', '2023-01-01', 4.9), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 2), (SELECT $node_id FROM Brands WHERE BrandID = 11), N'Официальный дилер', '2023-01-01', 4.9), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 4), (SELECT $node_id FROM Brands WHERE BrandID = 6),  N'Авторизованный сервис', '2023-01-01', 4.7), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 5), (SELECT $node_id FROM Brands WHERE BrandID = 3),  N'Универсальный', '2023-01-01', 4.3),
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 5), (SELECT $node_id FROM Brands WHERE BrandID = 6),  N'Универсальный', '2023-01-01', 4.3),
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 5), (SELECT $node_id FROM Brands WHERE BrandID = 7),  N'Универсальный', '2023-01-01', 4.3),
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 5), (SELECT $node_id FROM Brands WHERE BrandID = 8),  N'Универсальный', '2023-01-01', 4.3),
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 5), (SELECT $node_id FROM Brands WHERE BrandID = 12), N'Универсальный', '2023-01-01', 4.3),
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 9), (SELECT $node_id FROM Brands WHERE BrandID = 3),  N'Специализированный ремонт', '2023-01-01', 4.2), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 9), (SELECT $node_id FROM Brands WHERE BrandID = 7),  N'Специализированный ремонт', '2023-01-01', 4.2), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 9), (SELECT $node_id FROM Brands WHERE BrandID = 8),  N'Специализированный ремонт', '2023-01-01', 4.2), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 9), (SELECT $node_id FROM Brands WHERE BrandID = 12), N'Специализированный ремонт', '2023-01-01', 4.2), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 12), (SELECT $node_id FROM Brands WHERE BrandID = 3),  N'Универсальный', '2023-01-01', 4.4), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 12), (SELECT $node_id FROM Brands WHERE BrandID = 6),  N'Универсальный', '2023-01-01', 4.4), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 12), (SELECT $node_id FROM Brands WHERE BrandID = 7),  N'Универсальный', '2023-01-01', 4.4), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 12), (SELECT $node_id FROM Brands WHERE BrandID = 9),  N'Универсальный', '2023-01-01', 4.4), 
    ((SELECT $node_id FROM ServiceCenters WHERE CenterID = 12), (SELECT $node_id FROM Brands WHERE BrandID = 11), N'Универсальный', '2023-01-01', 4.4); 
GO

SELECT * FROM SERVES

-- 3. PURCHASES: Customer -> Model
INSERT INTO PURCHASES ($from_id, $to_id, PurchaseDate, PurchasePrice, PaymentMethod, WarrantyYears, IsTradeIn)
VALUES
    -- Иван Петров купил X5
    ((SELECT $node_id FROM Customers WHERE CustomerID = 1), (SELECT $node_id FROM Models WHERE ModelID = 1),  '2024-03-15', 8500000.00, N'Банковская карта', 4, 1),
    -- Мария Сидорова купила Camry
    ((SELECT $node_id FROM Customers WHERE CustomerID = 2), (SELECT $node_id FROM Models WHERE ModelID = 2),  '2024-02-20', 3500000.00, N'Наличные',         3, 0),
    -- Алексей Козлов купил Model S
    ((SELECT $node_id FROM Customers WHERE CustomerID = 3), (SELECT $node_id FROM Models WHERE ModelID = 3),  '2024-04-10', 12000000.00, N'Банковская карта', 5, 0),
    -- Елена Новикова купила Tucson
    ((SELECT $node_id FROM Customers WHERE CustomerID = 4), (SELECT $node_id FROM Models WHERE ModelID = 7),  '2024-01-25', 2800000.00, N'Наличные',         3, 1),
    -- Дмитрий Соколов купил Sportage
    ((SELECT $node_id FROM Customers WHERE CustomerID = 5), (SELECT $node_id FROM Models WHERE ModelID = 11), '2024-05-12', 2600000.00, N'Банковская карта', 3, 0),
    -- Анна Морозова купила XC90
    ((SELECT $node_id FROM Customers WHERE CustomerID = 6), (SELECT $node_id FROM Models WHERE ModelID = 8),  '2024-03-18', 7200000.00, N'Наличные',         4, 1),
    -- Сергей Волков купил 911
    ((SELECT $node_id FROM Customers WHERE CustomerID = 7), (SELECT $node_id FROM Models WHERE ModelID = 9),  '2024-06-22', 11500000.00, N'Банковская карта', 4, 0),
    -- Ольга Лебедева купила RX
    ((SELECT $node_id FROM Customers WHERE CustomerID = 8), (SELECT $node_id FROM Models WHERE ModelID = 10), '2024-04-30', 6100000.00, N'Наличные',         4, 0),
    -- Михаил Павлов купил Mustang
    ((SELECT $node_id FROM Customers WHERE CustomerID = 9), (SELECT $node_id FROM Models WHERE ModelID = 6),  '2024-02-14', 5800000.00, N'Банковская карта', 3, 1),
    -- Татьяна Егорова купила Model 3
    ((SELECT $node_id FROM Customers WHERE CustomerID = 10), (SELECT $node_id FROM Models WHERE ModelID = 12), '2024-05-25', 5500000.00, N'Наличные',         5, 0),
    -- Андрей Григорьев купил Golf
    ((SELECT $node_id FROM Customers WHERE CustomerID = 11), (SELECT $node_id FROM Models WHERE ModelID = 5),  '2024-03-08', 2100000.00, N'Банковская карта', 3, 0),
    -- Наталья Романова купила A4
    ((SELECT $node_id FROM Customers WHERE CustomerID = 12), (SELECT $node_id FROM Models WHERE ModelID = 4),  '2024-06-01', 4200000.00, N'Наличные',         3, 1);
GO

SELECT * FROM PURCHASES

--Запросы с функцией MATCH

-- 1. Найти клиентов, купивших электромобили, и вывести их имя, модель, марку и страну производителя.
SELECT
    c.CustomerFirstName + N' ' + c.CustomerSecondName AS [Клиент],
    m.ModelName AS [Модель],
    b.BrandName AS [Марка],
    b.CountryOfOrigin AS [Страна]
FROM Customers c, PURCHASES p, Models m, BELONGS_TO bt, Brands b
WHERE MATCH(c-(p)->m-(bt)->b)
  AND m.IsElectric = 1
ORDER BY b.BrandName;
GO

-- 2. Найти сервисные центры в городе клиента, которые обслуживают марку его автомобиля.
SELECT DISTINCT
    sc.CenterName AS [Сервисный центр],
    b.BrandName AS [Обслуживаемая марка],
    s.SpecializationLevel AS [Тип обслуживания]
FROM Customers c, PURCHASES p, Models m, BELONGS_TO bt, Brands b, SERVES s, ServiceCenters sc
WHERE MATCH(c-(p)->m-(bt)->b<-(s)-sc)
  AND c.City = sc.City
ORDER BY sc.CenterName;
GO

-- 3. Рассчитать количество продаж и среднюю цену покупки для каждого типа кузова каждой марки.
SELECT
    b.BrandName AS [Марка],
    m.BodyType AS [Тип кузова],
    COUNT(*) AS [Количество продаж],
    AVG(p.PurchasePrice) AS [Средняя цена]
FROM Customers c, PURCHASES p, Models m, BELONGS_TO bt, Brands b
WHERE MATCH(c-(p)->m-(bt)->b)
GROUP BY b.BrandName, m.BodyType
ORDER BY b.BrandName, [Средняя цена] DESC;
GO

-- 4. Найти клиентов с уровнем лояльности Gold или Platinum, купивших автомобили с рейтингом безопасности ≥ 4.8 марки BMW.
SELECT
    c.CustomerFirstName + N' ' + c.CustomerSecondName AS [Клиент],
    c.LoyaltyLevel AS [Уровень лояльности],
    b.BrandName AS [Марка],
    m.ModelName AS [Модель],
    m.SafetyRating AS [Рейтинг безопасности]
FROM Customers c, PURCHASES p, Models m, BELONGS_TO bt, Brands b
WHERE MATCH(c-(p)->m-(bt)->b)
  AND c.LoyaltyLevel IN (N'Platinum', N'Gold')
  AND m.SafetyRating >= 4.8
  AND b.BrandName = N'BMW' 
ORDER BY m.SafetyRating DESC, m.ModelName ASC;
GO

-- 5. Выявить марки автомобилей, у которых нет официальных дилеров в городах проживания их покупателей.
SELECT DISTINCT
    b.BrandName AS [Марка],
    c.City AS [Город клиента],
    c.CustomerFirstName + N' ' + c.CustomerSecondName AS [Клиент]
FROM Customers c, PURCHASES p, Models m, BELONGS_TO bt, Brands b
WHERE MATCH(c-(p)->m-(bt)->b)
  AND NOT EXISTS (
      SELECT 1 FROM ServiceCenters sc, SERVES s
      WHERE MATCH(sc-(s)->b)
        AND sc.City = c.City
        AND s.SpecializationLevel = N'Официальный дилер'
  )
ORDER BY b.BrandName, c.City;
GO


-- Запросы с функцией SHORTEST_PATH

-- Запрос 1: Все кратчайшие пути от BMW через сервисные центры (шаблон +)
-- Находим все бренды, куда можно добраться из BMW, проходя через хотя бы
-- один сервисный центр.
WITH PathsCTE AS (
    SELECT
        b1.BrandName AS [Начальная марка],
        CONCAT(
            b1.BrandName, '->',
            STRING_AGG(CONCAT(sc.CenterName, '->', b2.BrandName), '->') 
                WITHIN GROUP (GRAPH PATH)
        ) AS [Путь],
        COUNT(b2.BrandName) WITHIN GROUP (GRAPH PATH) AS [Шагов],
        LAST_VALUE(b2.BrandName) WITHIN GROUP (GRAPH PATH) AS [Конечный бренд]
    FROM
        Brands AS b1,
        SERVES FOR PATH AS s1,
        ServiceCenters FOR PATH AS sc,
        SERVES FOR PATH AS s2,
        Brands FOR PATH AS b2
    WHERE MATCH(
        SHORTEST_PATH(b1(<-(s1)-sc-(s2)->b2)+)
    )
      AND b1.BrandName = N'BMW'
)
SELECT * 
FROM PathsCTE
ORDER BY [Шагов], [Конечный бренд];
GO

-- Запрос 2: Найти кратчайшие пути от Tesla до BMW, проходящие через минимум 3 сервисных центра. Прямые и короткие связи (1–2 шага) исключить, чтобы выявить только косвенные партнёрские цепочки. Максимальная глубина обхода — 6 переходов.
WITH PathCTE AS (
    SELECT
        b1.BrandName AS [Начальная марка],
        CONCAT(
            b1.BrandName, '->',
            STRING_AGG(CONCAT(sc.CenterName, '->', b2.BrandName), '->') 
                WITHIN GROUP (GRAPH PATH)
        ) AS [Путь],
        COUNT(b2.BrandName) WITHIN GROUP (GRAPH PATH) AS [Шагов],
        LAST_VALUE(b2.BrandName) WITHIN GROUP (GRAPH PATH) AS [Конечный бренд]
    FROM
        Brands AS b1,
        SERVES FOR PATH AS s1,
        ServiceCenters FOR PATH AS sc,
        SERVES FOR PATH AS s2,
        Brands FOR PATH AS b2
    WHERE MATCH(
        SHORTEST_PATH(b1(<-(s1)-sc-(s2)->b2){1,6})
    )
      AND b1.BrandName = N'Tesla'
)
SELECT [Начальная марка], [Путь], [Шагов], [Конечный бренд]
FROM PathCTE
WHERE [Конечный бренд] = N'BMW'
  AND [Шагов] >= 3;
GO