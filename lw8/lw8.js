// 11.Студенты, нормативы по физкультуре, результаты.

use db_lw8
db.createCollection('students')
db.createCollection('sport_standards')
db.createCollection('results')
db.createCollection('groups')
db.createCollection('courses')

// 3.1 Отобразить коллекции базы данных
db.getCollectionNames()

// 3.2 Вставка записей
// 3.2.1 Вставка одной записи insertOne
db.groups.insertOne({name: 'ПС'})
db.courses.insertOne({course: 1})
db.students.insertOne({
    first_name: 'Александр',
    last_name: 'Клочко',
    group_id: db.groups.findOne({_id: ObjectId('650adac84fc0a7ed6a251ba9')})._id,
    course_id: db.courses.findOne({_id: ObjectId('650af59e4fc0a7ed6a251bb1')})._id
})
db.students.insertOne({
    first_name: 'Крутой',
    last_name: 'Человек',
    group_id: db.groups.findOne({_id: ObjectId('650adac84fc0a7ed6a251ba9')})._id,
    course_id: db.courses.findOne({_id: ObjectId('650af59e4fc0a7ed6a251bb1')})._id,
    family: ['mom', 'dad']
})
db.sport_standards.insertOne({name: 'running', standard: 10})
db.results.insertOne({
    standard_id: db.sport_standards.findOne({_id: ObjectId('650af28f4fc0a7ed6a251bab')})._id,
    student_id: db.students.findOne({_id: ObjectId('650af1584fc0a7ed6a251baa')})._id,
    result: 9
})
// 3.2.2 Вставка нескольких записей insertMany
db.groups.insertMany([
    {
        name: 'БИ'
    },
    {
        name: 'ИВТ'
    }
])
db.courses.insertMany([
    {
        course: 2
    },
    {
        course: 3
    },
    {
        course: 4
    }
])
db.students.insertMany([
    {
        first_name: 'Максим',
        last_name: 'Смешной',
        group_id: db.groups.findOne({_id: ObjectId('650af5374fc0a7ed6a251baf')})._id,
        course_id: db.courses.findOne({_id: ObjectId('650af2ba4fc0a7ed6a251bac')})._id
    },
    {
        first_name: 'Илья',
        last_name: 'Производственный',
        group_id: db.groups.findOne({_id: ObjectId('650af5374fc0a7ed6a251bae')})._id,
        course_id: db.courses.findOne({_id: ObjectId('650af59e4fc0a7ed6a251bb0')})._id
    },
    {
        first_name: 'Олег',
        last_name: 'Бдшник',
        group_id: db.groups.findOne({_id: ObjectId('650adac84fc0a7ed6a251ba9')})._id,
        course_id: db.courses.findOne({_id: ObjectId('650af59e4fc0a7ed6a251bb2')})._id
    }
])
db.sport_standards.insertMany([
    {
        name: 'squeezing',
        standard: 20
    },
    {
        name: 'squats',
        standard: 50,
    }
])
db.results.insertMany([
    {
        standard_id: db.sport_standards.findOne({_id: ObjectId('650af8b14fc0a7ed6a251bb6')})._id,
        student_id: db.students.findOne({_id: ObjectId('650af7e74fc0a7ed6a251bb4')})._id,
        result: 28
    },
    {
        standard_id: db.sport_standards.findOne({_id: ObjectId('650af8b14fc0a7ed6a251bb7')})._id,
        student_id: db.students.findOne({_id: ObjectId('650af7e74fc0a7ed6a251bb4')})._id,
        result: 63
    },
    {
        standard_id: db.sport_standards.findOne({_id: ObjectId('650af8b14fc0a7ed6a251bb7')})._id,
        student_id: db.students.findOne({_id: ObjectId('650af7e74fc0a7ed6a251bb5')})._id,
        result: 63
    },
    {
        standard_id: db.sport_standards.findOne({_id: ObjectId('650af28f4fc0a7ed6a251bab')})._id,
        student_id: db.students.findOne({_id: ObjectId('650af7e74fc0a7ed6a251bb5')})._id,
        result: 12
    }
])

// 3.3 Удаление записей
// 3.3.1 Удаление одной записи по условию deleteOne
db.results.deleteOne({result: 12})
// 3.3.2 Удаление нескольких записей по условию deleteMany
db.results.deleteMany({result: 63})

// 3.4 Поиск записей
// 3.4.1 Поиск по ID
db.students.findOne({_id: ObjectId('650af7e74fc0a7ed6a251bb5')})
// 3.4.2 Поиск записи по атрибуту первого уровня
db.students.findOne({first_name: 'Александр'})
// 3.4.3 Поиск записи по вложенному атрибуту
db.students.findOne({example: {exp: 1}})
// 3.4.4 Поиск записи по нескольким атрибутам (логический оператор AND)
db.students.find({
    '$and': [
        {first_name: 'Александр'},
        {last_name: 'Клочко'}
    ]
})
// 3.4.5 Поиск записи по одному из условий (логический оператор OR)
db.students.find({
    '$or': [
        {first_name: 'Александр'},
        {first_name: 'Олег'}
    ]
})
// 3.4.6 Поиск с использованием оператора сравнения
db.sport_standards.find({standard: {$gt: 40}})
// 3.4.7 Поиск с использованием двух операторов сравнения
db.sport_standards.find({standard: {$gt: 15, $lt: 50}})
// 3.4.8 Поиск по значению в массиве
db.students.find({family: 'mom'})
// 3.4.9 Поиск по количеству элементов в массиве
db.students.find({family: {$size: 2}})
// 3.4.10 Поиск записей без атрибута
db.students.find({family: {$exists: false}})

// 3.5 Обновление записей
// 3.5.1 Изменить значение атрибута у записи
db.students.updateOne({first_name: 'Крутой'}, {'$set': {last_name: 'Чувак'}})
// 3.5.3 Добавить атрибут записи
db.students.updateOne({first_name: 'Александр'}, {$set: {family: ['mom', 'sister']}})
// 3.5.2 Удалить атрибут у записи
db.students.updateOne({first_name: 'Александр'}, {$unset: {family: ''}})