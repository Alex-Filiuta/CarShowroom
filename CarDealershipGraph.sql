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
    CustomerSecondName NVARCHAR(100) NOT NULL,
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
('АвтоПремиум Минск', 'пр-т Независимости, 95', '+375 17 234-56-78', 'info@autopremium.by', 'Минск', 'Официальный дилер премиум-брендов', '09:00', '20:00', 4.8, 1),
('Тойота Центр Гомель', 'ул. Советская, 120', '+375 232 45-67-89', 'service@toyota-gomel.by', 'Гомель', 'Официальный дилер Toyota', '08:00', '21:00', 4.9, 1),
('ЭлектроАвто Сервис', 'ул. Новая, 25', '+375 17 345-67-89', 'ev@electroauto.by', 'Минск', 'Специализированный сервис по электромобилям', '10:00', '19:00', 4.6, 0),
('Немецкое Качество', 'пр-т Победителей, 120', '+375 17 456-78-90', 'info@germanquality.by', 'Минск', 'Авторизованный сервис BMW, Mercedes, Audi', '09:00', '20:00', 4.7, 0),
('АвтоСити Брест', 'ул. Московская, 51', '+375 162 56-78-90', 'service@autocity-brest.by', 'Брест', 'Универсальный сервис', '09:00', '19:00', 4.3, 0),
('Корейские Авто Витебск', 'пр-т Фрунзе, 82', '+375 212 67-89-01', 'info@koreanauto-vitebsk.by', 'Витебск', 'Официальный дилер Hyundai, Kia', '09:00', '20:00', 4.5, 1),
('Вольво Центр Гродно', 'ул. Горького, 141', '+375 152 78-90-12', 'service@volvo-grodno.by', 'Гродно', 'Официальный дилер Volvo', '09:00', '18:00', 4.8, 1),
('Порше Центр Минск', 'ул. Немига, 11', '+375 17 890-12-34', 'info@porsche-minsk.by', 'Минск', 'Официальный дилер Porsche', '10:00', '19:00', 4.9, 1),
('АвтоМастер Могилев', 'ул. Ленинская, 176', '+375 222 90-12-34', 'service@avtomaster-mogilev.by', 'Могилев', 'Специализированный ремонт', '09:00', '18:00', 4.2, 0),
('Тесла Сервис Минск', 'ул. Тимирязева, 10', '+375 17 012-34-56', 'service@tesla-minsk.by', 'Минск', 'Официальный сервисный центр Tesla', '09:00', '21:00', 4.9, 1),
('Форд Центр Бобруйск', 'ул. Социалистическая, 32', '+375 241 12-34-56', 'info@ford-bobruisk.by', 'Бобруйск', 'Официальный дилер Ford', '09:00', '20:00', 4.6, 1),
('АвтоЭксперт Барановичи', 'ул. Советская, 45', '+375 163 23-45-67', 'service@autoexpert-baranovichi.by', 'Барановичи', 'Универсальный сервис', '09:00', '19:00', 4.4, 0);
GO

-- Заполнение Customers
INSERT INTO Customers (CustomerFirstName, CustomerSecondName, Email, PhoneNumber, City, RegistrationDate, LoyaltyLevel) VALUES
('Иван', 'Петров', 'ivan.petrov@gmail.com', '+375 29 111-22-33', 'Минск', '2023-01-15', 'Gold'),
('Мария', 'Сидорова', 'maria.sidorova@gmail.com', '+375 29 222-33-44', 'Гомель', '2023-02-20', 'Silver'),
('Алексей', 'Козлов', 'alexey.kozlov@gmail.com', '+375 29 333-44-55', 'Минск', '2023-03-10', 'Platinum'),
('Елена', 'Новикова', 'elena.novikova@gmail.com', '+375 29 444-55-66', 'Брест', '2023-04-05', 'Bronze'),
('Дмитрий', 'Соколов', 'dmitry.sokolov@gmail.com', '+375 29 555-66-77', 'Витебск', '2023-05-12', 'Silver'),
('Анна', 'Морозова', 'anna.morozova@gmail.com', '+375 29 666-77-88', 'Гродно', '2023-06-18', 'Gold'),
('Сергей', 'Волков', 'sergey.volkov@gmail.com', '+375 29 777-88-99', 'Могилев', '2023-07-22', 'Bronze'),
('Ольга', 'Лебедева', 'olga.lebedeva@gmail.com', '+375 29 888-99-00', 'Минск', '2023-08-30', 'Platinum'),
('Михаил', 'Павлов', 'mikhail.pavlov@gmail.com', '+375 29 999-00-11', 'Бобруйск', '2023-09-14', 'Silver'),
('Татьяна', 'Егорова', 'tatyana.egorova@gmail.com', '+375 29 000-11-22', 'Барановичи', '2023-10-25', 'Gold'),
('Андрей', 'Григорьев', 'andrey.grigoriev@gmail.com', '+375 29 111-22-33', 'Пинск', '2023-11-08', 'Bronze'),
('Наталья', 'Романова', 'natalya.romanova@gmail.com', '+375 29 222-33-44', 'Минск', '2023-12-01', 'Silver');
GO

--Заполнение таблиц рёбер

-- =============================================================================
-- Заполнение BELONGS_TO (Модель → Марка)
-- =============================================================================
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

-- =============================================================================
-- Заполнение SERVES (Сервисный центр → Марка)
-- =============================================================================
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

-- =============================================================================
-- Заполнение PURCHASES (Клиент → Модель)
-- =============================================================================
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

--Запросы с функцией MATCH

-- 1. Найти клиентов, купивших электромобили, и вывести их имя, модель, марку и страну производителя.
SELECT
    c.CustomerFirstName + ' ' + c.CustomerSecondName AS [Клиент],
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
    c.CustomerFirstName + ' ' + c.CustomerSecondName AS [Клиент],
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
    c.CustomerFirstName + ' ' + c.CustomerSecondName AS [Клиент]
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
SELECT 
    c.CustomerFirstName + ' ' + c.CustomerSecondName AS [Клиент],
    STRING_AGG(m.ModelName, ' -> ') WITHIN GROUP (GRAPH PATH) AS [Путь_через_модели],
    LAST_NODE(b).BrandName AS [Конечная_марка]
FROM 
    Customers c,
    Models m FOR PATH,
    Brands b FOR PATH,
    PURCHASES p FOR PATH,
    BELONGS_TO bt FOR PATH
WHERE 
    MATCH(SHORTEST_PATH(c(-(p)->m-(bt)->b)+))
    AND c.CustomerFirstName = N'Иван'
GROUP BY 
    c.CustomerFirstName, c.CustomerSecondName;
GO

-- 2. Найти кратчайший путь от марки «Tesla» к клиентам длиной от 1 до 3 шагов, вывести имена всех промежуточных моделей и конечного клиента.
SELECT 
    b.BrandName AS [Марка],
    STRING_AGG(m.ModelName, ' -> ') WITHIN GROUP (GRAPH PATH) AS [Промежуточные_модели],
    LAST_NODE(c).CustomerFirstName + ' ' + LAST_NODE(c).CustomerSecondName AS [Конечный_клиент]
FROM 
    Brands b,
    Models m FOR PATH,
    Customers c FOR PATH,
    BELONGS_TO bt FOR PATH,
    PURCHASES p FOR PATH
WHERE 
    MATCH(SHORTEST_PATH((b <-(bt)- m <-(p)- c){1,3}))
    AND b.BrandName = N'Tesla'
GROUP BY 
    b.BrandName;
GO