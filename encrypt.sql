--创建数据库主密钥
CREATE MASTER KEY ENCRYPTION BY PASSWORD ='Pa$$word'
--创建证书
CREATE CERTIFICATE CertTest 
with SUBJECT = 'Test Certificate'
GO
--创建非对称密钥
CREATE ASYMMETRIC KEY TestAsymmetric
    WITH ALGORITHM = RSA_2048 
    ENCRYPTION BY PASSWORD = 'pa$$word'; 
GO
--创建对称密钥
CREATE SYMMETRIC KEY TestSymmetric
    WITH ALGORITHM = AES_256
    ENCRYPTION BY PASSWORD = 'pa$$word';
GO

--由证书加密对称密钥
CREATE SYMMETRIC KEY SymmetricByCert
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE CertTest;
GO
--由对称密钥加密对称密钥
OPEN SYMMETRIC KEY TestSymmetric
    DECRYPTION BY PASSWORD='pa$$word'

CREATE SYMMETRIC KEY SymmetricBySy
    WITH ALGORITHM = AES_256
    ENCRYPTION BY SYMMETRIC KEY TestSymmetric;
GO
--由非对称密钥加密对称密钥

CREATE SYMMETRIC KEY SymmetricByAsy
    WITH ALGORITHM = AES_256
    ENCRYPTION BY ASYMMETRIC KEY TestASymmetric;
GO

SELECT CustomerId, 
Name,
Location_encrypt = CONVERT(varbinary(500), Location), 
Email
INTO dbo.Customers_Encrypt
FROM dbo.Customers
WHERE 1<>1

--打开之前创建的由证书加密的对称密钥
OPEN SYMMETRIC KEY SymmetricByCert
DECRYPTION BY CERTIFICATE CertTest
--利用这个密钥加密数据并插入新建的表
insert dbo.Customers_Encrypt (
CustomerId, 
Name,
Location_encrypt, 
Email
) 
select top 10
CustomerId,
Name,
Location_encrypt = EncryptByKey(KEY_GUID('SymmetricByCert'), Location),
Email
from dbo.Customers


SELECT CONVERT(varbinary(500), Location_encrypt)
FROM dbo.Customers_Encrypt

-- 查看加密数据
OPEN SYMMETRIC KEY SymmetricByCert
DECRYPTION BY CERTIFICATE CertTest

select CustomerId, 
Name,
Location = convert(nvarchar(25), DecryptByKey(Location_encrypt)), 
Email
from dbo.Customers_Encrypt