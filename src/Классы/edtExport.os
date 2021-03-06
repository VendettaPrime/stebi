#Использовать logos
#Использовать v8metadata-reader

Перем _Лог;
Перем _РезультатПроверки;
Перем _ФайлДжсон;
Перем _КаталогИсходников;
Перем _ВыгружатьОшибкиОбъектов;

Перем ГенераторПутей;

Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Аргумент("EDT_VALIDATION_RESULT", "" ,"Путь к файлу с результатом проверки edt. Например ./edt-result.out")
	.ТСтрока()
	.ВОкружении("EDT_VALIDATION_RESULT");
	
	Команда.Аргумент("EDT_VALIDATION_JSON", "" ,"Путь к файлу результату. Например ./edt-json.json")
	.ТСтрока()
	.ВОкружении("EDT_VALIDATION_JSON");
	
	Команда.Аргумент("SRC", "" ,"Путь к каталогу с исходниками. Например ./src")
	.ТСтрока()
	.ВОкружении("SRC");
	
	Команда.Опция("e ObjectErrors", Ложь, "Ошибки объектов назначать на первую строку модуля формы/объекта");
	
КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Команда) Экспорт
	
	ИнициализацияПараметров(Команда);
	
	таблицаРезультатов = ТаблицаПоФайлуРезультата();
	
	ЗаполнитьВТаблицеРезультатовИсходныеПути( таблицаРезультатов );
	ЗаполнитьВТаблицеРезультатовНомераСтрок( таблицаРезультатов );
	
	записьВДжсон = Новый ЗаписьReportJSON( _ФайлДжсон, _Лог );
	записьВДжсон.Записать( таблицаРезультатов );
	
КонецПроцедуры

Процедура ИнициализацияПараметров(Знач Команда)
	
	результатПроверки = Команда.ЗначениеАргумента("EDT_VALIDATION_RESULT");
	_лог.Отладка( "EDT_VALIDATION_RESULT = " + результатПроверки );
	путьКРезультату = Команда.ЗначениеАргумента("EDT_VALIDATION_JSON");
	_лог.Отладка( "EDT_VALIDATION_JSON = " + путьКРезультату );
	путьККаталогуИсходников = Команда.ЗначениеАргумента("SRC");
	_лог.Отладка( "SRC = " + путьККаталогуИсходников );
	
	_РезультатПроверки = ОбщегоНазначения.АбсолютныйПуть( результатПроверки );
	_лог.Отладка( "Файл с результатом проверки EDT = " + _РезультатПроверки );
	
	Если Не ОбщегоНазначения.ФайлСуществует(_РезультатПроверки) Тогда
		
		_лог.Ошибка( СтрШаблон("Файл с результатом проверки <%1> не существует.", результатПроверки) );
		ЗавершитьРаботу(1);
		
	КонецЕсли;
	
	_КаталогИсходников = ОбщегоНазначения.АбсолютныйПуть(путьККаталогуИсходников);
	каталогИсходников = Новый Файл(_КаталогИсходников);
	_лог.Отладка( "Каталог исходников = " + _КаталогИсходников );
	
	Если Не каталогИсходников.Существует()
		Или Не каталогИсходников.ЭтоКаталог() Тогда
		
		_лог.Ошибка( СтрШаблон("Каталог исходников <%1> не существует.", путьККаталогуИсходников) );
		ЗавершитьРаботу(1);
		
	КонецЕсли;
	
	_ФайлДжсон = ОбщегоНазначения.АбсолютныйПуть( путьКРезультату );    
	_лог.Отладка( "Файл результат = " + _ФайлДжсон );
	
	_ВыгружатьОшибкиОбъектов = Команда.ЗначениеОпции("ObjectErrors");

	ГенераторПутей = Новый Путь1СПоМетаданным(_КаталогИсходников);
	
КонецПроцедуры

Функция ТаблицаПоФайлуРезультата()
	
	_Лог.Отладка( "Чтение файла результата %1", _РезультатПроверки );
	
	тз = Новый ТаблицаЗначений;
	тз.Колонки.Добавить( "ДатаОбнаружения" );
	тз.Колонки.Добавить( "Тип" );
	тз.Колонки.Добавить( "Проект" );
	тз.Колонки.Добавить( "Метаданные" );
	тз.Колонки.Добавить( "Положение" );
	тз.Колонки.Добавить( "Описание" );
	
	ЧтениеТекста = Новый ЧтениеТекста( _РезультатПроверки, КодировкаТекста.UTF8 );
	
	ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
	
	КОЛОНКА_ПОЛОЖЕНИЕ = 4;
	КОЛОНКА_ОПИСАНИЕ = 5;

	всегоОшибок = 0;

	Пока Не ПрочитаннаяСтрока = Неопределено Цикл
		
		Если ПустаяСтрока( ПрочитаннаяСтрока ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		всегоОшибок = всегоОшибок + 1;

		компонентыСтроки = СтрРазделить( ПрочитаннаяСтрока, "	" );
		
		положение = компонентыСтроки[КОЛОНКА_ПОЛОЖЕНИЕ];
		
		Если Не _ВыгружатьОшибкиОбъектов
			И (Не ЗначениеЗаполнено( положение )
			ИЛИ Не СтрНачинаетсяС( ВРег( положение ), "СТРОКА" )) Тогда
			// Нас интересуют только ошибки в модулях, а у них есть положение.
			ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;

		началоОписания = компонентыСтроки[КОЛОНКА_ОПИСАНИЕ];

		Если ЗначениеЗаполнено(началоОписания)
			И СтрНачинаетсяС(началоОписания, "[BSL LS]") Тогда
			// Пропускаем ошибки от плагина, т.к. BSL-LS отдельно выполняет проверку
			
			ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
			Продолжить;

		КонецЕсли;
		
		ПереопределитьПути(компонентыСтроки);

		новСтрока = тз.Добавить();
		
		Для ц = 0 По КОЛОНКА_ПОЛОЖЕНИЕ Цикл
			
			новСтрока[ц] = компонентыСтроки[ц];
			
		КонецЦикла;
		
		// В описании могут быть и табы, по которым делим
		
		Для ц = КОЛОНКА_ОПИСАНИЕ По компонентыСтроки.ВГраница() Цикл
			
			Если ЗначениеЗаполнено( новСтрока.Описание ) Тогда
				
				новСтрока.Описание = новСтрока.Описание + "	";
				
			Иначе
				
				новСтрока.Описание = "";
				
			КонецЕсли;
			
			новСтрока.Описание = новСтрока.Описание + компонентыСтроки[ц];
			
		КонецЦикла;
		
		ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
		
	КонецЦикла;
	
	ЧтениеТекста.Закрыть();
	
	_Лог.Информация("Из файла %1 прочитано %2 строк из %3", _РезультатПроверки, тз.Количество(), всегоОшибок);
	
	// В отчете могут быть дубли
	
	тз.Свернуть("Тип,Метаданные,Положение,Описание");
	
	Возврат тз;
	
КонецФункции

Процедура ПереопределитьПути( компонентыСтроки )
	
	Если Не _ВыгружатьОшибкиОбъектов Тогда

		Возврат;

	КонецЕсли;

	КОЛОНКА_ОПИСАНИЕ = 5;
	КОЛОНКА_ПОЛОЖЕНИЕ = 4;
	КОЛОНКА_МЕТА = 3;

	положение = компонентыСтроки[КОЛОНКА_ПОЛОЖЕНИЕ];
	
	Если СтрНачинаетсяС( ВРег( положение ), "СТРОКА" ) Тогда
		
		Возврат;

	КонецЕсли;

	мета = компонентыСтроки[КОЛОНКА_МЕТА];

	Если СтрЗаканчиваетсяНа( ВРег( мета ), ".ФОРМА" ) Тогда
		// Вешаем на модуль формы

		компонентыСтроки[КОЛОНКА_МЕТА] = мета + ".Модуль";

	ИначеЕсли СтрРазделить( мета, "." ).Количество() = 2 Тогда

		Если ПутьКМетаданнымСуществует(мета + ".МодульОбъекта") Тогда

			компонентыСтроки[КОЛОНКА_МЕТА] = мета + ".МодульОбъекта";

		ИначеЕсли ПутьКМетаданнымСуществует(мета + ".МодульМенеджера") Тогда

			компонентыСтроки[КОЛОНКА_МЕТА] = мета + ".МодульМенеджера";

		ИначеЕсли ПутьКМетаданнымСуществует(мета + ".МодульНабораЗаписей") Тогда

			компонентыСтроки[КОЛОНКА_МЕТА] = мета + ".МодульНабораЗаписей";

		ИначеЕсли ПутьКМетаданнымСуществует(мета + ".МодульМенеджераЗначения") Тогда

			компонентыСтроки[КОЛОНКА_МЕТА] = мета + ".МодульМенеджераЗначения";

		ИначеЕсли ПутьКМетаданнымСуществует(мета + ".МодульКоманды") Тогда

			компонентыСтроки[КОЛОНКА_МЕТА] = мета + ".МодульКоманды";

		Иначе

			компонентыСтроки[КОЛОНКА_МЕТА] = "Конфигурация.МодульУправляемогоПриложения";
			компонентыСтроки[КОЛОНКА_ОПИСАНИЕ] = мета + ": " + компонентыСтроки[КОЛОНКА_ОПИСАНИЕ];

		КонецЕсли;

	ИначеЕсли СтрНачинаетсяС(ВРег( мета ), "ПОДСИСТЕМА.") Тогда

		компонентыСтроки[КОЛОНКА_МЕТА] = "Конфигурация.МодульУправляемогоПриложения";
		компонентыСтроки[КОЛОНКА_ОПИСАНИЕ] = мета + ": " + компонентыСтроки[КОЛОНКА_ОПИСАНИЕ];	

	Иначе

		_Лог.Предупреждение( "Не переопределен путь для %1", мета );

		компонентыСтроки[КОЛОНКА_МЕТА] = "Конфигурация.МодульУправляемогоПриложения";
		компонентыСтроки[КОЛОНКА_ОПИСАНИЕ] = мета + ": " + компонентыСтроки[КОЛОНКА_ОПИСАНИЕ];
		
	КонецЕсли;

	компонентыСтроки[КОЛОНКА_ПОЛОЖЕНИЕ] = "Строка 1";
	
КонецПроцедуры

Процедура ЗаполнитьВТаблицеРезультатовИсходныеПути( таблицаРезультатов )
	
	таблицаРезультатов.Колонки.Добавить("Путь");
	
	Для каждого цСтрока Из таблицаРезультатов Цикл
		
		цСтрока.Путь = генераторПутей.Путь(цСтрока.Метаданные);
		
		Если Не ПроверитьПуть( цСтрока.Путь, цСтрока.Метаданные ) Тогда

			цСтрока.Путь = "";

		КонецЕсли;
		
	КонецЦикла;

	поискСтрокКУдалению = Новый Структура("Путь", "");

	Для каждого цСтрокаКУдалению Из таблицаРезультатов.НайтиСтроки(поискСтрокКУдалению) Цикл

		таблицаРезультатов.Удалить(цСтрокаКУдалению);

	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаполнитьВТаблицеРезультатовНомераСтрок( таблицаРезультатов )
	
	таблицаРезультатов.Колонки.Добавить("НомерСтроки");
	
	Для каждого цСтрока Из таблицаРезультатов Цикл
		
		цСтрока.НомерСтроки = СтрЗаменить( ВРег( цСтрока.Положение ), "СТРОКА ", "" );
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПутьКМетаданнымСуществует(Знач пМетаданные)

	Путь = генераторПутей.Путь(пМетаданные);
		
	Возврат ПроверитьПуть(Путь, пМетаданные, Ложь);

КонецФункции

Функция ПроверитьПуть(Знач пПуть, Знач пМетаданные = "", Знач пСообщать = Истина)
	
	Если Не ЗначениеЗаполнено( пПуть ) Тогда
		
		Если пСообщать Тогда

			_лог.Ошибка( СтрШаблон( "Путь для <%1> не получен", пМетаданные) );

		КонецЕсли;

		Возврат Ложь;
		
	ИначеЕсли Не ОбщегоНазначения.ФайлСуществует( пПуть ) Тогда
		
		Если пСообщать Тогда

			_лог.Ошибка( СтрШаблон( "Путь <%1> для <%2> не существует", пПуть, пМетаданные) );

		КонецЕсли;

		Возврат Ложь;

	Иначе

		Возврат Истина;
		
	КонецЕсли;
	
КонецФункции

Функция ИмяЛога() Экспорт
	Возврат "oscript.app." + ОПриложении.Имя();
КонецФункции

_Лог = Логирование.ПолучитьЛог(ИмяЛога());