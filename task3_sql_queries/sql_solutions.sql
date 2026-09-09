
SELECT g.CITY_NAME, g.NASELENIE
  FROM gorod g
       JOIN region r ON r.ID = g.REGION_ID
 WHERE r.ID = 1
 ORDER BY g.NASELENIE;

SELECT COUNT(*)
  FROM gorod g 
 WHERE g.NASELENIE IS NULL;
 
SELECT g.CITY_NAME
  FROM gorod g 
 WHERE g.NASELENIE = (SELECT max(g.NASELENIE)
                        FROM gorod g);

DELETE 
  FROM gorod g
 WHERE g.NASELENIE <400000;


UPDATE gorod g
   SET g.NASELENIE = 200000
 WHERE g.REGION_ID = 1;

SELECT g.CITY_NAME 
  FROM gorod g
 WHERE LOWER(g.CITY_NAME) LIKE LOWER('К%');
 
SELECT r.REGION_NAME, 
     COUNT(g.CITY_NAME) AS city_count
FROM gorod g
     JOIN region r ON r.ID = g.REGION_ID
GROUP BY r.REGION_NAME;

CREATE GLOBAL TEMPORARY TABLE temp_region_city_count (
  region_name VARCHAR2(2000),
  city_count  NUMBER
) ON COMMIT PRESERVE ROWS;

DECLARE
  CURSOR c_gorod IS
     SELECT r.REGION_NAME, 
            COUNT(g.CITY_NAME) AS city_count
       FROM "Gorod_region".gorod g
            JOIN "Gorod_region".region r ON r.ID = g.REGION_ID
       GROUP BY r.REGION_NAME;
    
  v_region_name "Gorod_region".region.region_name%TYPE;
  v_city_count  NUMBER;

BEGIN
  OPEN c_gorod; -- Открытие курсора
  LOOP -- Цикл для обхода всех записей курсора
    FETCH c_gorod INTO v_region_name, v_city_count; -- Извлечение данных из курсора в переменные
    EXIT WHEN c_gorod%NOTFOUND;

    -- Вставка данных во временную таблицу
    INSERT INTO temp_region_city_count (region_name, city_count)
    VALUES (v_region_name, v_city_count);
  END LOOP;
  
  CLOSE c_gorod; -- Закрытие курсора
END;
/

-- Извлекаем данные из временной таблицы
SELECT REGION_NAME, CITY_COUNT
  FROM temp_region_city_count;

-- Удаляем временную таблицу, если она больше не нужна
DROP TABLE temp_region_city_count;

/* Данные будут выведены списокм */
DECLARE
  CURSOR c_gorod IS
     SELECT r.REGION_NAME, 
            COUNT(g.CITY_NAME) AS city_count
       FROM gorod g
            JOIN region r ON r.ID = g.REGION_ID
       GROUP BY r.REGION_NAME;
    
  v_region_name r.REGION_NAME%TYPE;
  v_city_count  NUMBER;

BEGIN
  OPEN c_gorod; -- Открытие курсора
  LOOP -- Цикл для обхода всех записей курсора
    FETCH c_gorod INTO v_region_name, v_city_count;  -- Извлечение данных из курсора в переменные
    EXIT WHEN c_gorod%NOTFOUND;
    
    DBMS_OUTPUT.PUT_LINE('Регион: ' || v_region_name || ' - Количество городов: ' || v_city_count); -- Вывод результата
  END LOOP;
  
  CLOSE c_gorod; -- Закрытие курсора
END;
/
