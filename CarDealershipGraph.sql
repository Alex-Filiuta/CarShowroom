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
    CustomerSecondName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    City NVARCHAR(100),
    RegistrationDate DATE DEFAULT GETDATE(),
    LoyaltyLevel NVARCHAR(50) CHECK (LoyaltyLevel IN (N'Bronze',N'Silver',N'Gold',N'Platinum'))
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
    CHECK (SpecializationLevel IN (N'Официальный дилер', N'Авторизованный сервис', N'Специализированный ремонт', N'Универсальный')),
    ContractStartDate DATE,
    ContractEndDate DATE,
    ServiceQualityRating DECIMAL(3,2);
GO

-- РЕБРО 3: PURCHASES (Модель куплена Клиентом)
-- Направление: Customers -> Models
CREATE TABLE PURCHASES AS EDGE;
GO

ALTER TABLE PURCHASES 
ADD CONSTRAINT EC_PURCHASES 
CONNECTION (Customers TO Models)
ON DELETE NO ACTION;
GO

ALTER TABLE PURCHASES 
ADD PurchaseDate DATE NOT NULL DEFAULT GETDATE(),
    PurchasePrice DECIMAL(12,2),
    PaymentMethod NVARCHAR(50) CHECK (PaymentMethod IN (N'Наличные', N'Банковская карта')),
    WarrantyYears INT,
    IsTradeIn BIT DEFAULT 0;
GO

--Заполнение таблиц узлов

-- Заполнение Brands
INSERT INTO Brands (BrandName, CountryOfOrigin, YearFounded, Website, IsManufacturerActive, Description) VALUES
(N'BMW', N'Germany', 1916, N'https://www.bmw.com', 1, N'Премиальные автомобили с акцентом на динамику'),
(N'Mercedes-Benz', N'Germany', 1926, N'https://www.mercedes-benz.com', 1, N'Роскошные автомобили и коммерческий транспорт'),
(N'Toyota', N'Japan', 1937, N'https://www.toyota.com', 1, N'Надёжные автомобили массового сегмента'),
(N'Tesla', N'USA', 2003, N'https://www.tesla.com', 1, N'Инновационные электромобили и энергетические решения'),
(N'Audi', N'Germany', 1909, N'https://www.audi.com', 1, N'Технологичные премиальные автомобили'),
(N'Volkswagen', N'Germany', 1937, N'https://www.volkswagen.com', 1, N'Автомобили для широкой аудитории'),
(N'Ford', N'USA', 1903, N'https://www.ford.com', 1, N'Американский автопроизводитель с богатой историей'),
(N'Hyundai', N'South Korea', 1967, N'https://www.hyundai.com', 1, N'Современные автомобили с отличным соотношением цены и качества'),
(N'Volvo', N'Sweden', 1927, N'https://www.volvo.com', 1, N'Безопасность и скандинавский дизайн'),
(N'Porsche', N'Germany', 1931, N'https://www.porsche.com', 1, N'Спортивные автомобили премиум-класса'),
(N'Lexus', N'Japan', 1989, N'https://www.lexus.com', 1, N'Премиальное подразделение Toyota'),
(N'Kia', N'South Korea', 1944, N'https://www.kia.com', 1, N'Динамично развивающийся корейский бренд');
GO

SELECT * FROM Brands

-- Заполнение Models
INSERT INTO Models (ModelName, ProductionStartYear, ProductionEndYear, BodyType, EngineType, Horsepower, FuelConsumption, TransmissionType, BasePrice, IsElectric, SafetyRating) VALUES
(N'X5', 1999, NULL, N'Внедорожник', N'Бензиновый', 340, 11.5, N'Автомат', 8500000.00, 0, 4.8),
(N'Camry', 1982, NULL, N'Седан', N'Бензиновый', 203, 8.6, N'Автомат', 3500000.00, 0, 4.9),
(N'Model S', 2012, NULL, N'Седан', N'Электрический', 670, 0, N'Автомат', 12000000.00, 1, 5.0),
(N'A4', 1994, NULL, N'Седан', N'Бензиновый', 249, 7.8, N'Автомат', 4200000.00, 0, 4.7),
(N'Golf', 1974, NULL, N'Хэтчбек', N'Бензиновый', 150, 6.4, N'Механика', 2100000.00, 0, 4.6),
(N'Mustang', 1964, NULL, N'Купе', N'Бензиновый', 450, 13.2, N'Автомат', 5800000.00, 0, 4.3),
(N'Tucson', 2004, NULL, N'Внедорожник', N'Бензиновый', 150, 8.9, N'Автомат', 2800000.00, 0, 4.5),
(N'XC90', 2002, NULL, N'Внедорожник', N'Гибрид', 310, 2.1, N'Автомат', 7200000.00, 0, 5.0),
(N'911', 1963, NULL, N'Купе', N'Бензиновый', 450, 11.1, N'Робот', 11500000.00, 0, 4.4),
(N'RX', 1998, NULL, N'Внедорожник', N'Гибрид', 313, 5.8, N'Автомат', 6100000.00, 0, 4.8),
(N'Sportage', 1993, NULL, N'Внедорожник', N'Бензиновый', 150, 9.1, N'Автомат', 2600000.00, 0, 4.4),
(N'Model 3', 2017, NULL, N'Седан', N'Электрический', 283, 0, N'Автомат', 5500000.00, 1, 5.0);
GO

SELECT * FROM Models

-- Заполнение ServiceCenters
INSERT INTO ServiceCenters (CenterName, Address, PhoneNumber, Email, City, Specialization, OpenTime, CloseTime, Rating, IsOfficialDealer) VALUES
(N'АвтоПремиум Минск', N'пр-т Независимости, 95', N'+375 17 234-56-78', N'info@autopremium.by', N'Минск', N'Официальный дилер премиум-брендов', N'09:00', N'20:00', 4.8, 1),
(N'Тойота Центр Гомель', N'ул. Советская, 120', N'+375 232 45-67-89', N'service@toyota-gomel.by', N'Гомель', N'Официальный дилер Toyota', N'08:00', N'21:00', 4.9, 1),
(N'ЭлектроАвто Сервис', N'ул. Новая, 25', N'+375 17 345-67-89', N'ev@electroauto.by', N'Минск', N'Специализированный сервис по электромобилям', N'10:00', N'19:00', 4.6, 0),
(N'Немецкое Качество', N'пр-т Победителей, 120', N'+375 17 456-78-90', N'info@germanquality.by', N'Минск', N'Авторизованный сервис BMW, Mercedes, Audi', N'09:00', N'20:00', 4.7, 0),
(N'АвтоСити Брест', N'ул. Московская, 51', N'+375 162 56-78-90', N'service@autocity-brest.by', N'Брест', N'Универсальный сервис', N'09:00', N'19:00', 4.3, 0),
(N'Корейские Авто Витебск', N'пр-т Фрунзе, 82', N'+375 212 67-89-01', N'info@koreanauto-vitebsk.by', N'Витебск', N'Официальный дилер Hyundai, Kia', N'09:00', N'20:00', 4.5, 1),
(N'Вольво Центр Гродно', N'ул. Горького, 141', N'+375 152 78-90-12', N'service@volvo-grodno.by', N'Гродно', N'Официальный дилер Volvo', N'09:00', N'18:00', 4.8, 1),
(N'Порше Центр Минск', N'ул. Немига, 11', N'+375 17 890-12-34', N'info@porsche-minsk.by', N'Минск', N'Официальный дилер Porsche', N'10:00', N'19:00', 4.9, 1),
(N'АвтоМастер Могилев', N'ул. Ленинская, 176', N'+375 222 90-12-34', N'service@avtomaster-mogilev.by', N'Могилев', N'Специализированный ремонт', N'09:00', N'18:00', 4.2, 0),
(N'Тесла Сервис Минск', N'ул. Тимирязева, 10', N'+375 17 012-34-56', N'service@tesla-minsk.by', N'Минск', N'Официальный сервисный центр Tesla', N'09:00', N'21:00', 4.9, 1),
(N'Форд Центр Бобруйск', N'ул. Социалистическая, 32', N'+375 241 12-34-56', N'info@ford-bobruisk.by', N'Бобруйск', N'Официальный дилер Ford', N'09:00', N'20:00', 4.6, 1),
(N'АвтоЭксперт Барановичи', N'ул. Советская, 45', N'+375 163 23-45-67', N'service@autoexpert-baranovichi.by', N'Барановичи', N'Универсальный сервис', N'09:00', N'19:00', 4.4, 0);
GO

SELECT * FROM ServiceCenters

-- Заполнение Customers
INSERT INTO Customers (CustomerFirstName, CustomerSecondName, Email, PhoneNumber, City, RegistrationDate, LoyaltyLevel) VALUES
(N'Иван', N'Петров', N'ivan.petrov@gmail.com', N'+375 29 111-22-33', N'Минск', '2023-01-15', N'Gold'),
(N'Мария', N'Сидорова', N'maria.sidorova@gmail.com', N'+375 29 222-33-44', N'Гомель', '2023-02-20', N'Silver'),
(N'Алексей', N'Козлов', N'alexey.kozlov@gmail.com', N'+375 29 333-44-55', N'Минск', '2023-03-10', N'Platinum'),
(N'Елена', N'Новикова', N'elena.novikova@gmail.com', N'+375 29 444-55-66', N'Брест', '2023-04-05', N'Bronze'),
(N'Дмитрий', N'Соколов', N'dmitry.sokolov@gmail.com', N'+375 29 555-66-77', N'Витебск', '2023-05-12', N'Silver'),
(N'Анна', N'Морозова', N'anna.morozova@gmail.com', N'+375 29 666-77-88', N'Гродно', '2023-06-18', N'Gold'),
(N'Сергей', N'Волков', N'sergey.volkov@gmail.com', N'+375 29 777-88-99', N'Могилев', '2023-07-22', N'Bronze'),
(N'Ольга', N'Лебедева', N'olga.lebedeva@gmail.com', N'+375 29 888-99-00', N'Минск', '2023-08-30', N'Platinum'),
(N'Михаил', N'Павлов', N'mikhail.pavlov@gmail.com', N'+375 29 999-00-11', N'Бобруйск', '2023-09-14', N'Silver'),
(N'Татьяна', N'Егорова', N'tatyana.egorova@gmail.com', N'+375 29 000-11-22', N'Барановичи', '2023-10-25', N'Gold'),
(N'Андрей', N'Григорьев', N'andrey.grigoriev@gmail.com', N'+375 29 111-22-33', N'Пинск', '2023-11-08', N'Bronze'),
(N'Наталья', N'Романова', N'natalya.romanova@gmail.com', N'+375 29 222-33-44', N'Минск', '2023-12-01', N'Silver');
GO

SELECT * FROM Customers

--Заполнение таблиц рёбер

-- Заполнение BELONGS_TO (Модель → Марка)
INSERT INTO BELONGS_TO ($from_id, $to_id, StartDate, IsCurrentModel)
SELECT m.$node_id, b.$node_id, v.StartDate, v.IsCurrentModel
FROM (VALUES
    (N'X5',       N'BMW',          '1999-01-01', 1),
    (N'Camry',    N'Toyota',       '1982-01-01', 1),
    (N'Model S',  N'Tesla',        '2012-01-01', 1),
    (N'A4',       N'Audi',         '1994-01-01', 1),
    (N'Golf',     N'Volkswagen',   '1974-01-01', 1),
    (N'Mustang',  N'Ford',         '1964-01-01', 1),
    (N'Tucson',   N'Hyundai',      '2004-01-01', 1),
    (N'XC90',     N'Volvo',        '2002-01-01', 1),
    (N'911',      N'Porsche',      '1963-01-01', 1),
    (N'RX',       N'Lexus',        '1998-01-01', 1),
    (N'Sportage', N'Kia',          '1993-01-01', 1),
    (N'Model 3',  N'Tesla',        '2017-01-01', 1)
) AS v(ModelName, BrandName, StartDate, IsCurrentModel)
JOIN Models m ON m.ModelName = v.ModelName
JOIN Brands b ON b.BrandName = v.BrandName;
GO

SELECT * FROM BELONGS_TO

-- Заполнение SERVES (Сервисный центр → Марка)
INSERT INTO SERVES ($from_id, $to_id, SpecializationLevel, ContractStartDate, ServiceQualityRating)
SELECT sc.$node_id, b.$node_id, v.Level, v.ContractStart, v.Rating
FROM (VALUES
    (N'АвтоПремиум Минск', N'BMW',           N'Официальный дилер',       '2023-01-01', 4.8),
    (N'АвтоПремиум Минск', N'Mercedes-Benz', N'Официальный дилер',       '2023-01-01', 4.8),
    (N'АвтоПремиум Минск', N'Audi',          N'Официальный дилер',       '2023-01-01', 4.8),
    (N'АвтоПремиум Минск', N'Porsche',       N'Официальный дилер',       '2023-01-01', 4.8),
    (N'Тойота Центр Гомель', N'Toyota',      N'Официальный дилер',       '2023-01-01', 4.8),
    (N'ЭлектроАвто Сервис', N'Tesla',        N'Специализированный ремонт','2023-01-01', 4.6),
    (N'Немецкое Качество', N'BMW',           N'Авторизованный сервис',   '2023-01-01', 4.7),
    (N'Немецкое Качество', N'Mercedes-Benz', N'Авторизованный сервис',   '2023-01-01', 4.7),
    (N'Немецкое Качество', N'Audi',          N'Авторизованный сервис',   '2023-01-01', 4.7),
    (N'АвтоСити Брест', N'BMW',              N'Универсальный',           '2023-01-01', 4.3),
    (N'АвтоСити Брест', N'Mercedes-Benz',    N'Универсальный',           '2023-01-01', 4.3),
    (N'АвтоСити Брест', N'Toyota',           N'Универсальный',           '2023-01-01', 4.3),
    (N'АвтоСити Брест', N'Tesla',            N'Универсальный',           '2023-01-01', 4.3),
    (N'АвтоСити Брест', N'Audi',             N'Универсальный',           '2023-01-01', 4.3),
    (N'АвтоСити Брест', N'Volkswagen',       N'Универсальный',           '2023-01-01', 4.3),
    (N'АвтоСити Брест', N'Ford',             N'Универсальный',           '2023-01-01', 4.3),
    (N'АвтоСити Брест', N'Hyundai',          N'Универсальный',           '2023-01-01', 4.3),
    (N'АвтоСити Брест', N'Volvo',            N'Универсальный',           '2023-01-01', 4.3),
    (N'АвтоСити Брест', N'Porsche',          N'Универсальный',           '2023-01-01', 4.3),
    (N'АвтоСити Брест', N'Lexus',            N'Универсальный',           '2023-01-01', 4.3),
    (N'АвтоСити Брест', N'Kia',              N'Универсальный',           '2023-01-01', 4.3),
    (N'Корейские Авто Витебск', N'Hyundai',  N'Официальный дилер',       '2023-01-01', 4.8),
    (N'Корейские Авто Витебск', N'Kia',      N'Официальный дилер',       '2023-01-01', 4.8),
    (N'Вольво Центр Гродно', N'Volvo',       N'Официальный дилер',       '2023-01-01', 4.8),
    (N'Порше Центр Минск', N'Porsche',       N'Официальный дилер',       '2023-01-01', 4.8),
    (N'АвтоМастер Могилев', N'BMW',          N'Специализированный ремонт','2023-01-01', 4.2),
    (N'АвтоМастер Могилев', N'Mercedes-Benz',N'Специализированный ремонт','2023-01-01', 4.2),
    (N'АвтоМастер Могилев', N'Toyota',       N'Специализированный ремонт','2023-01-01', 4.2),
    (N'АвтоМастер Могилев', N'Tesla',        N'Специализированный ремонт','2023-01-01', 4.2),
    (N'АвтоМастер Могилев', N'Audi',         N'Специализированный ремонт','2023-01-01', 4.2),
    (N'АвтоМастер Могилев', N'Volkswagen',   N'Специализированный ремонт','2023-01-01', 4.2),
    (N'АвтоМастер Могилев', N'Ford',         N'Специализированный ремонт','2023-01-01', 4.2),
    (N'АвтоМастер Могилев', N'Hyundai',      N'Специализированный ремонт','2023-01-01', 4.2),
    (N'АвтоМастер Могилев', N'Volvo',        N'Специализированный ремонт','2023-01-01', 4.2),
    (N'АвтоМастер Могилев', N'Porsche',      N'Специализированный ремонт','2023-01-01', 4.2),
    (N'АвтоМастер Могилев', N'Lexus',        N'Специализированный ремонт','2023-01-01', 4.2),
    (N'АвтоМастер Могилев', N'Kia',          N'Специализированный ремонт','2023-01-01', 4.2),
    (N'Тесла Сервис Минск', N'Tesla',        N'Официальный дилер',       '2023-01-01', 4.8),
    (N'Форд Центр Бобруйск', N'Ford',        N'Официальный дилер',       '2023-01-01', 4.8),
    (N'АвтоЭксперт Барановичи', N'BMW',      N'Универсальный',           '2023-01-01', 4.4),
    (N'АвтоЭксперт Барановичи', N'Mercedes-Benz', N'Универсальный',      '2023-01-01', 4.4),
    (N'АвтоЭксперт Барановичи', N'Toyota',   N'Универсальный',           '2023-01-01', 4.4),
    (N'АвтоЭксперт Барановичи', N'Tesla',    N'Универсальный',           '2023-01-01', 4.4),
    (N'АвтоЭксперт Барановичи', N'Audi',     N'Универсальный',           '2023-01-01', 4.4),
    (N'АвтоЭксперт Барановичи', N'Volkswagen',N'Универсальный',           '2023-01-01', 4.4),
    (N'АвтоЭксперт Барановичи', N'Ford',     N'Универсальный',           '2023-01-01', 4.4),
    (N'АвтоЭксперт Барановичи', N'Hyundai',  N'Универсальный',           '2023-01-01', 4.4),
    (N'АвтоЭксперт Барановичи', N'Volvo',    N'Универсальный',           '2023-01-01', 4.4),
    (N'АвтоЭксперт Барановичи', N'Porsche',  N'Универсальный',           '2023-01-01', 4.4),
    (N'АвтоЭксперт Барановичи', N'Lexus',    N'Универсальный',           '2023-01-01', 4.4),
    (N'АвтоЭксперт Барановичи', N'Kia',      N'Универсальный',           '2023-01-01', 4.4)
) AS v(CenterName, BrandName, Level, ContractStart, Rating)
JOIN ServiceCenters sc ON sc.CenterName = v.CenterName
JOIN Brands b ON b.BrandName = v.BrandName;
GO

SELECT * FROM SERVES

-- Заполнение PURCHASES (Клиент → Модель)
INSERT INTO PURCHASES ($from_id, $to_id, PurchaseDate, PurchasePrice, PaymentMethod, WarrantyYears, IsTradeIn)
SELECT c.$node_id, m.$node_id, v.PurchaseDate, v.PurchasePrice, v.PaymentMethod, v.WarrantyYears, v.IsTradeIn
FROM (VALUES
    (N'Иван',    N'Петров',    N'X5',       '2024-03-15', 8500000.00,  N'Банковская карта', 4, 1),
    (N'Мария',   N'Сидорова',  N'Camry',    '2024-02-20', 3500000.00,  N'Наличные',         3, 0),
    (N'Алексей', N'Козлов',    N'Model S',  '2024-04-10', 12000000.00, N'Банковская карта', 5, 0),
    (N'Елена',   N'Новикова',  N'Tucson',   '2024-01-25', 2800000.00,  N'Наличные',         3, 1),
    (N'Дмитрий', N'Соколов',   N'Sportage', '2024-05-12', 2600000.00,  N'Банковская карта', 3, 0),
    (N'Анна',    N'Морозова',  N'XC90',     '2024-03-18', 7200000.00,  N'Наличные',         4, 1),
    (N'Сергей',  N'Волков',    N'911',      '2024-06-22', 11500000.00, N'Банковская карта', 4, 0),
    (N'Ольга',   N'Лебедева',  N'RX',       '2024-04-30', 6100000.00,  N'Наличные',         4, 0),
    (N'Михаил',  N'Павлов',    N'Mustang',  '2024-02-14', 5800000.00,  N'Банковская карта', 3, 1),
    (N'Татьяна', N'Егорова',   N'Model 3',  '2024-05-25', 5500000.00,  N'Наличные',         5, 0),
    (N'Андрей',  N'Григорьев', N'Golf',     '2024-03-08', 2100000.00,  N'Банковская карта', 3, 0),
    (N'Наталья', N'Романова',  N'A4',       '2024-06-01', 4200000.00,  N'Наличные',         3, 1)
) AS v(FirstName, SecondName, ModelName, PurchaseDate, PurchasePrice, PaymentMethod, WarrantyYears, IsTradeIn)
JOIN Customers c ON c.CustomerFirstName = v.FirstName AND c.CustomerSecondName = v.SecondName
JOIN Models m ON m.ModelName = v.ModelName;
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
  AND b.BrandName = N'BMW'  -- ← добавлено
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

-- 1. Найти кратчайший путь от клиента «Иван» к брендам через историю покупок, вывести цепочку моделей и название конечной марки.
WITH PathToBrands AS
(
    SELECT
        c.CustomerFirstName + N' ' + c.CustomerSecondName AS [Клиент],
        STRING_AGG(m.ModelName, N' -> ') WITHIN GROUP (GRAPH PATH) AS [Цепочка_моделей],
        LAST_VALUE(b.BrandName) WITHIN GROUP (GRAPH PATH) AS [Конечная_марка]
    FROM
        Customers AS c,
        PURCHASES FOR PATH AS p,
        Models FOR PATH AS m,
        BELONGS_TO FOR PATH AS bt,
        Brands FOR PATH AS b
    WHERE
        MATCH(SHORTEST_PATH(c(-(p)->m-(bt)->b)+))
        AND c.CustomerFirstName = N'Иван'
)
SELECT [Клиент], [Цепочка_моделей], [Конечная_марка]
FROM PathToBrands
WHERE [Конечная_марка] = N'BMW'; -- Фильтрация по LastNode, как в примере с Глебом
GO

-- 2. Найти кратчайший путь от марки «Tesla» к клиентам длиной от 1 до 3 шагов, вывести имена всех промежуточных моделей и конечного клиента.
SELECT 
    b.BrandName AS [Марка],
    STRING_AGG(m.ModelName, N' -> ') WITHIN GROUP (GRAPH PATH) AS [Промежуточные_модели],
    LAST_VALUE(c.CustomerFirstName) WITHIN GROUP (GRAPH PATH) + N' ' + LAST_VALUE(c.CustomerSecondName) WITHIN GROUP (GRAPH PATH) AS [Конечный_клиент]
FROM 
    Brands b,
    Models FOR PATH AS m,
    Customers FOR PATH AS c,
    BELONGS_TO FOR PATH AS bt,
    PURCHASES FOR PATH AS p
WHERE 
    MATCH(SHORTEST_PATH((b <-(bt)- m <-(p)- c){1,3}))
    AND b.BrandName = N'Tesla';
GO

SELECT @@VERSION;  -- версия сервера
SELECT name, compatibility_level
FROM sys.databases
WHERE name = N'CarDealershipGraph';