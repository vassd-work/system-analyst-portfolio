# Скрипты Postman для API-тестирования

### Тест на наличие ошибки
Принцип работы - в теле ответа запроса проверяет наличие тегов <error> или <message>
При успешном выполнении возвращает сообщение "< error > или < message > не обнаружены"
При ошибке возвращает сообщения:
* Есть ошибка в < error > или < message > 
* Ответ error: <текст ошибки>
Особенности: в Postman тест всегда будет со статусом PASSED, так как при любом результате будет отрабатывает корректно, но выводить разные сообщения.
Использовать: в Collection → Scripts → Post-response.
 ```
// Получение тела ответа
let responseJson = pm.response.json();
 
// Извлечение значений для сообщения и ошибки
let responseBodyM = responseJson.message;
let responseBodyE = responseJson.error;
 
// Список тегов, которые нужно проверить
let tagsToCheck = ["error", "message"];
 
// Функция для проверки наличия тегов
function hasAnyTag(tags) {
    return tags.some(tag => responseJson.hasOwnProperty(tag));
}
 
// Функция для проверки отсутствия тегов
function checkAbsentTags(tags) {
    return tags.every(tag => !responseJson.hasOwnProperty(tag));
}
 
// Проверка наличия тегов в теле ответа
if (hasAnyTag(tagsToCheck)) {
    // Проверка отсутствия всех тегов в теле ответа
    pm.test("Есть ошибка в < error > или < message >", function () {
        let allTagsAbsent = checkAbsentTags(tagsToCheck);
        pm.expect(allTagsAbsent).to.be.false; // Ожидаем, что теги есть
    });
 
    // Вывод информации о значении 'message', если оно есть
    if (responseJson.message) {
        pm.test(`Ответ message: ${responseBodyM}`, function () {
            pm.expect(true).to.be.true; // Тест не будет пройден
        });
    }
 
    // Вывод информации о значении 'error', если оно есть
    if (responseJson.error) {
        pm.test(`Ответ error: ${responseBodyE}`, function () {
            pm.expect(true).to.be.true; // Тест не будет пройден
        });
    }
} else { 
    // Код, который будет выполнен, если тегов нет
    pm.test("< error > или < message > не обнаружены", function () {
        // Это условие будет выполнено только в случае отсутствия тегов
        pm.expect(true).to.be.true; // Тест будет пройден
    });
}
``` 
---
### Данные переменных в консоль
Выводит данные, полученные из переменных, в консоль в формате PUT - org:<значение переменной>, id:<значение переменной>.
Особенность: не работает с переменными, созданными в скриптах.
Использовать: в Request → Scripts → Pre-request.
```
console.log("PUT -  org:", pm.collectionVariables.get("<variable_code>"), "id:", pm.collectionVariables.get("variable_code"));
``` 
---
### Проверка статус-кода (ОР = ФР) 
Выводит в результаты теста информацию о соответствии или несоответствии статус-кода. Для проверки другого кода нужно изменить значение в тесте.
Использовать: в Request → Scripts → Post-response.
```
// Проверка, что статус-код ответа 200
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});
```
---
### Проверка наличия параметра в теле ответа
Проверяет наличие одного или нескольких параметров в теле ответа и меняет статус теста PASSED / FAILED в зависимости от результата.
Использовать: в Request → Scripts → Post-response.
```
// Получение тела ответа
let responseJson = pm.response.json();
 
// Проверка наличия полей в ответе
if (responseJson) {
    pm.test("Поле 'status' есть в ответе", function () {
        pm.expect(responseJson).to.have.property("status");
    });
}
```
```
// Получение тела ответа
let responseJson = pm.response.json();
 
// Проверка наличия полей в ответе
if (responseJson) {
    pm.test("Поле 'id' есть в ответе", function () {
        pm.expect(responseJson).to.have.property("id");
    });
 
    pm.test("Поле 'org' есть в ответе", function () {
        pm.expect(responseJson).to.have.property("org");
    });
 
    pm.test("Поле 'smpPriorityRef' есть в ответе", function () {
        pm.expect(responseJson).to.have.property("smpPriorityRef");
    });
 
    pm.test("Поле 'smpReasonRef' есть в ответе", function () {
        pm.expect(responseJson).to.have.property("smpReasonRef");
    });
 
    pm.test("Поле 'smpReason' есть в ответе", function () {
        pm.expect(responseJson).to.have.property("smpReason");
    });
}
```
---
### Проверка на соответствие текста ошибки
Проверяет наличие текста ошибки, например из ЧТЗ, на совпадение с ответом. Ожидаемые слова берутся из переменной expectedWords_id.
Использовать: в Request → Scripts → Post-response.
```
// Проверяем статус ответа (исправлен текст теста)
pm.test("Status code is 404", function () {
    pm.response.to.have.status(404);
});
 
// Получение тела ответа
let responseJson;
 
try {
    responseJson = pm.response.json();
} catch (e) {
    pm.test("Ответ содержит корректный JSON", function () {
        pm.expect.fail("Ответ не является валидным JSON");
    });
}
 
// Проверяем, есть ли поле 'message'
if (responseJson && responseJson.hasOwnProperty("message")) {
    let messageText = responseJson.message.toLowerCase(); // Приводим к нижнему регистру
 
    // Получаем список ожидаемых слов из переменной коллекции или окружения
    let expectedWords_id = pm.collectionVariables.get("expectedWords_id") || pm.environment.get("expectedWords_id");
 
    if (expectedWords_id) {
        let wordsArray = expectedWords_id.toLowerCase().split(",").map(word => word.trim()); // Преобразуем в массив
 
        pm.test(`Поле 'message' содержит одно из ожидаемых слов: ${expectedWords_id}`, function () {
            let found = wordsArray.some(word => messageText.includes(word));
            pm.expect(found).to.be.true;
        });
    } else {
        console.log("Ожидаемые слова не заданы в переменной 'expectedWords_id'");
    }
} else {
    pm.test("Поле 'message' присутствует в ответе", function () {
        pm.expect(responseJson).to.have.property("message");
    });
}
```
---
### Сохранение значения результата в переменную
Сохраняет значение параметра result из тела ответа в переменную коллекции POSTresultValue, которую затем можно использовать в параметрах или теле следующего запроса.
Использовать: в Request → Scripts → Post-response.
```
 // Получение тела ответа
let responseJson = pm.response.json();
 
// Проверяем, есть ли поле result
if (responseJson.hasOwnProperty("result")) {
    let resultValue = responseJson.result;
 
    // Сохраняем значение в переменную коллекции
    pm.collectionVariables.set("POSTresultValue", resultValue);
 
    console.log("Сохранено в переменную коллекции: POSTresultValue =", resultValue);
} else {
    console.log("Поле 'result' отсутствует в ответе");
}
 
// Проверка наличия полей в ответе
if (responseJson) {
    pm.test("Поле 'result' есть в ответе", function () {
        pm.expect(responseJson).to.have.property("result");
    });
}
 ```
 ---
### Проверка на соответствие текста ошибки (с указанием текста в тесте)
Проверяет наличие текста ошибки на совпадение с ответом.
Особенность: ожидаемый текст ошибки указывается прямо в тесте.
Использовать: в Request → Scripts → Post-response.
```
// Получение тела ответа
let responseJson;
 
try {
    responseJson = pm.response.json();
    console.log("Ответ JSON:", responseJson); // Логируем ответ JSON
} catch (e) {
    pm.test("Ответ содержит корректный JSON", function () {
        pm.expect.fail("Ответ не является валидным JSON");
    });
}
 
// Проверяем, есть ли поле 'message'
if (responseJson && responseJson.hasOwnProperty("message")) {
    console.log("Поле 'message' присутствует."); // Логируем факт наличия поля 'message'
    let messageText = responseJson.message ? responseJson.message.toLowerCase().trim() : ''; // Приводим к нижнему регистру и убираем пробелы
 
    // Логирование для проверки содержимого messageText
    console.log("Полученное сообщение:", messageText);
 
    // Ожидаемые слова, которые можно прямо указать в тесте
    const expectedWords = ["Произошло дублирование записи по полям 'Организация (ссылка)', 'Причина обращения' Сохранение невозможно."];
 
    pm.test(`Поле 'message' содержит ожидаемую ошибку: ${expectedWords.join(", ")}`, function () {
        let found = expectedWords.some(word => messageText.includes(word.toLowerCase().trim()));
        pm.expect(found).to.be.true;
    });
}
```
---
### Проверка группы полей и группы вложенных полей в теле ответа
Проверяет группу полей верхнего уровня и поля вложенных объектов. responseFields — поля ответа, nestedFields — поля вложенных объектов.
Использовать: в Request → Scripts → Post-response.
```
let response = pm.response.json();
 
// Группируем проверки для параметров на уровне response
const responseFields = [
    "id",
    "org",
    "rangeTypeRef",
    "rangeType",
    "beginNumber",
    "beginNumberInfo",
    "endNumber",
    "endNumberInfo",
    "isActual"
];
 
responseFields.forEach(field => {
    pm.test(`Проверка: response.${field}`, function () {
        pm.expect(response).to.have.property(field);
    });
});
 
// Проверка для вложенных объектов (journal, givenMedOrg)
const nestedFields = {
    "rangeType": ["ident", "description"],
    "beginNumberInfo": ["valueInt", "valueStr"],
    "endNumberInfo": ["valueInt", "valueStr"]
};
 
Object.keys(nestedFields).forEach(key => {
    if (response[key]) {
        nestedFields[key].forEach(field => {
            pm.test(`Проверка: response.${key}.${field}`, function () {
                pm.expect(response[key]).to.have.property(field);
            });
        });
    }
});
```
---
### Проверка группы полей и группы вложенных полей в items тела ответа
Проверяет поля верхнего уровня и поля внутри items, включая вложенные объекты. fields — поля элемента, nestedObjects — поля вложенных объектов.
Использовать: в Request → Scripts → Post-response.
```
// Получение тела ответа
let responseJson = pm.response.json();
 
// Проверка верхнего уровня
pm.test("Проверка наличия totalElements", function () {
    pm.expect(responseJson).to.have.property("totalElements");
});
 
pm.test("Проверка наличия items", function () {
    pm.expect(responseJson).to.have.property("items").that.is.an("array");
});
 
// Проверка полей внутри items
let item = responseJson.items[0];
 
const fields = [
    "id", "org", "rangeTypeRef", "rangeType", "beginNumber",
    "beginNumberInfo","endNumber", "endNumberInfo", "isActual"
];
 
fields.forEach(field => {
    pm.test(`Проверка: '${field}'`, function () {
        pm.expect(item).to.have.property(field);
    });
});
 
// Проверка вложенных объектов
const nestedObjects = {
    "rangeType": ["ident", "description"],
    "beginNumberInfo": ["valueInt", "valueStr"],
    "endNumberInfo": ["valueInt", "valueStr"]
};
 
Object.keys(nestedObjects).forEach(key => {
    let obj = key.split('.').reduce((o, i) => (o ? o[i] : undefined), item);
    pm.test(`Проверка: '${key}'`, function () {
        pm.expect(obj).to.be.an("object");
    });
    nestedObjects[key].forEach(field => {
        pm.test(`Проверка '${field}' в объекте '${key}'`, function () {
            pm.expect(obj).to.have.property(field);
        });
    });
});
```
