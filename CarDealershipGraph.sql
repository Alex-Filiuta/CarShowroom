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
('АвтоПремиум Москва', 'ул. Ленинградский проспект, 39', '+7 495 123-45-67', 'info@autopremium.ru', 'Москва', 'Официальный дилер премиум-брендов', '09:00', '20:00', 4.8, 1),
('Тойота Центр СПб', 'пр. Энгельса, 154', '+7 812 234-56-78', 'service@toyota-spb.ru', 'Санкт-Петербург', 'Официальный дилер Toyota', '08:00', '21:00', 4.9, 1),
('ЭлектроАвто Сервис', 'ул. Новая, 25', '+7 495 345-67-89', 'ev@electroauto.ru', 'Москва', 'Специализированный сервис по электромобилям', '10:00', '19:00', 4.6, 0),
('Немецкое Качество', 'ш. Ярославское, 120', '+7 495 456-78-90', 'info@germanquality.ru', 'Москва', 'Авторизованный сервис BMW, Mercedes, Audi', '09:00', '20:00', 4.7, 0),
('АвтоСити Екатеринбург', 'ул. Малышева, 51', '+7 343 567-89-01', 'service@autocity-ekb.ru', 'Екатеринбург', 'Универсальный сервис', '09:00', '19:00', 4.3, 0),
('Корейские Авто Новосибирск', 'ул. Красный проспект, 82', '+7 383 678-90-12', 'info@koreanauto-nsk.ru', 'Новосибирск', 'Официальный дилер Hyundai, Kia', '09:00', '20:00', 4.5, 1),
('Вольво Центр Казань', 'пр. Победы, 141', '+7 843 789-01-23', 'service@volvo-kzn.ru', 'Казань', 'Официальный дилер Volvo', '09:00', '18:00', 4.8, 1),
('Порше Центр Сочи', 'ул. Навагинская, 11', '+7 862 890-12-34', 'info@porsche-sochi.ru', 'Сочи', 'Официальный дилер Porsche', '10:00', '19:00', 4.9, 1),
('АвтоМастер Краснодар', 'ул. Красная, 176', '+7 861 901-23-45', 'service@avtomaster-krd.ru', 'Краснодар', 'Специализированный ремонт', '09:00', '18:00', 4.2, 0),
('Тесла Сервис Москва', 'ул. Тестовская, 10', '+7 495 012-34-56', 'service@tesla-msk.ru', 'Москва', 'Официальный сервисный центр Tesla', '09:00', '21:00', 4.9, 1),
('Форд Центр Ростов', 'пр. Михаила Нагибина, 32', '+7 863 123-45-67', 'info@ford-rostov.ru', 'Ростов-на-Дону', 'Официальный дилер Ford', '09:00', '20:00', 4.6, 1),
('АвтоЭксперт Воронеж', 'ул. Плехановская, 45', '+7 473 234-56-78', 'service@autoexpert-vrn.ru', 'Воронеж', 'Универсальный сервис', '09:00', '19:00', 4.4, 0);
GO

-- Заполнение Customers
INSERT INTO Customers (CustomerFirstName, CustomerSecondName, Email, PhoneNumber, City, RegistrationDate, LoyaltyLevel) VALUES
('Иван', 'Петров', 'ivan.petrov@email.ru', '+7 916 111-22-33', 'Москва', '2023-01-15', 'Gold'),
('Мария', 'Сидорова', 'maria.sidorova@email.ru', '+7 926 222-33-44', 'Санкт-Петербург', '2023-02-20', 'Silver'),
('Алексей', 'Козлов', 'alexey.kozlov@email.ru', '+7 903 333-44-55', 'Москва', '2023-03-10', 'Platinum'),
('Елена', 'Новикова', 'elena.novikova@email.ru', '+7 985 444-55-66', 'Екатеринбург', '2023-04-05', 'Bronze'),
('Дмитрий', 'Соколов', 'dmitry.sokolov@email.ru', '+7 912 555-66-77', 'Новосибирск', '2023-05-12', 'Silver'),
('Анна', 'Морозова', 'anna.morozova@email.ru', '+7 918 666-77-88', 'Казань', '2023-06-18', 'Gold'),
('Сергей', 'Волков', 'sergey.volkov@email.ru', '+7 987 777-88-99', 'Сочи', '2023-07-22', 'Bronze'),
('Ольга', 'Лебедева', 'olga.lebedeva@email.ru', '+7 921 888-99-00', 'Москва', '2023-08-30', 'Platinum'),
('Михаил', 'Павлов', 'mikhail.pavlov@email.ru', '+7 961 999-00-11', 'Краснодар', '2023-09-14', 'Silver'),
('Татьяна', 'Егорова', 'tatyana.egorova@email.ru', '+7 909 000-11-22', 'Ростов-на-Дону', '2023-10-25', 'Gold'),
('Андрей', 'Григорьев', 'andrey.grigoriev@email.ru', '+7 915 111-22-33', 'Воронеж', '2023-11-08', 'Bronze'),
('Наталья', 'Романова', 'natalya.romanova@email.ru', '+7 927 222-33-44', 'Москва', '2023-12-01', 'Silver');
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
    CROSS JOIN Brands b
    WHERE 
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
    CROSS JOIN Brands b
    WHERE 
        (sc.CenterName = 'АвтоПремиум Москва' AND b.BrandName IN ('BMW', 'Mercedes-Benz', 'Audi', 'Porsche')) OR
        (sc.CenterName = 'Тойота Центр СПб' AND b.BrandName = 'Toyota') OR
        (sc.CenterName = 'ЭлектроАвто Сервис' AND b.BrandName = 'Tesla') OR
        (sc.CenterName = 'Немецкое Качество' AND b.BrandName IN ('BMW', 'Mercedes-Benz', 'Audi')) OR
        (sc.CenterName = 'АвтоСити Екатеринбург') OR
        (sc.CenterName = 'Корейские Авто Новосибирск' AND b.BrandName IN ('Hyundai', 'Kia')) OR
        (sc.CenterName = 'Вольво Центр Казань' AND b.BrandName = 'Volvo') OR
        (sc.CenterName = 'Порше Центр Сочи' AND b.BrandName = 'Porsche') OR
        (sc.CenterName = 'АвтоМастер Краснодар') OR
        (sc.CenterName = 'Тесла Сервис Москва' AND b.BrandName = 'Tesla') OR
        (sc.CenterName = 'Форд Центр Ростов' AND b.BrandName = 'Ford') OR
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
            WHEN c.CustomerFirstName = 'Иван' AND c.CustomerSecondName = 'Петров' AND m.ModelName = 'X5' THEN '2024-03-15'
            WHEN c.CustomerFirstName = 'Мария' AND c.CustomerSecondName = 'Сидорова' AND m.ModelName = 'Camry' THEN '2024-02-20'
            WHEN c.CustomerFirstName = 'Алексей' AND c.CustomerSecondName = 'Козлов' AND m.ModelName = 'Model S' THEN '2024-04-10'
            WHEN c.CustomerFirstName = 'Елена' AND c.CustomerSecondName = 'Новикова' AND m.ModelName = 'Tucson' THEN '2024-01-25'
            WHEN c.CustomerFirstName = 'Дмитрий' AND c.CustomerSecondName = 'Соколов' AND m.ModelName = 'Sportage' THEN '2024-05-12'
            WHEN c.CustomerFirstName = 'Анна' AND c.CustomerSecondName = 'Морозова' AND m.ModelName = 'XC90' THEN '2024-03-18'
            WHEN c.CustomerFirstName = 'Сергей' AND c.CustomerSecondName = 'Волков' AND m.ModelName = '911' THEN '2024-06-22'
            WHEN c.CustomerFirstName = 'Ольга' AND c.CustomerSecondName = 'Лебедева' AND m.ModelName = 'RX' THEN '2024-04-30'
            WHEN c.CustomerFirstName = 'Михаил' AND c.CustomerSecondName = 'Павлов' AND m.ModelName = 'Mustang' THEN '2024-02-14'
            WHEN c.CustomerFirstName = 'Татьяна' AND c.CustomerSecondName = 'Егорова' AND m.ModelName = 'Model 3' THEN '2024-05-25'
            WHEN c.CustomerFirstName = 'Андрей' AND c.CustomerSecondName = 'Григорьев' AND m.ModelName = 'Golf' THEN '2024-03-08'
            WHEN c.CustomerFirstName = 'Наталья' AND c.CustomerSecondName = 'Романова' AND m.ModelName = 'A4' THEN '2024-06-01'
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
    CROSS JOIN Models m
    WHERE 
        (c.CustomerFirstName = 'Иван' AND c.CustomerSecondName = 'Петров' AND m.ModelName = 'X5') OR
        (c.CustomerFirstName = 'Мария' AND c.CustomerSecondName = 'Сидорова' AND m.ModelName = 'Camry') OR
        (c.CustomerFirstName = 'Алексей' AND c.CustomerSecondName = 'Козлов' AND m.ModelName = 'Model S') OR
        (c.CustomerFirstName = 'Елена' AND c.CustomerSecondName = 'Новикова' AND m.ModelName = 'Tucson') OR
        (c.CustomerFirstName = 'Дмитрий' AND c.CustomerSecondName = 'Соколов' AND m.ModelName = 'Sportage') OR
        (c.CustomerFirstName = 'Анна' AND c.CustomerSecondName = 'Морозова' AND m.ModelName = 'XC90') OR
        (c.CustomerFirstName = 'Сергей' AND c.CustomerSecondName = 'Волков' AND m.ModelName = '911') OR
        (c.CustomerFirstName = 'Ольга' AND c.CustomerSecondName = 'Лебедева' AND m.ModelName = 'RX') OR
        (c.CustomerFirstName = 'Михаил' AND c.CustomerSecondName = 'Павлов' AND m.ModelName = 'Mustang') OR
        (c.CustomerFirstName = 'Татьяна' AND c.CustomerSecondName = 'Егорова' AND m.ModelName = 'Model 3') OR
        (c.CustomerFirstName = 'Андрей' AND c.CustomerSecondName = 'Григорьев' AND m.ModelName = 'Golf') OR
        (c.CustomerFirstName = 'Наталья' AND c.CustomerSecondName = 'Романова' AND m.ModelName = 'A4')
) AS source
ON target.$from_id = source.from_id AND target.$to_id = source.to_id
WHEN NOT MATCHED THEN
    INSERT ($from_id, $to_id, PurchaseDate, PurchasePrice, PaymentMethod, WarrantyYears)
    VALUES (source.from_id, source.to_id, source.PurchaseDate, source.PurchasePrice, 'Кредит', 3);
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
