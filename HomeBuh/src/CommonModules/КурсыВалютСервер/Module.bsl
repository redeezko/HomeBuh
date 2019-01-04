
Процедура ЗагрузитьКурсВалютыЗаПериод(ДатаНачала, ДатаОкончания, Валюта) Экспорт
	ВебСервис = WSСсылки.КурсВалютЦБ.СоздатьWSПрокси("http://web.cbr.ru/", "DailyInfo", "DailyInfoSoap");
	
	//Получаем тип параметра, который передается в метод GetCursOnDate.
	//@skip-warning
	ТипWSПараметра = ВебСервис.ФабрикаXDTO.Пакеты.Получить("http://web.cbr.ru/").Получить("GetCursDynamic");	
	
	//Создаем параметр на основе типа и заполняем значение параметров.
	WSПараметр	   			= ВебСервис.ФабрикаXDTO.Создать(ТипWSПараметра);
	WSПараметр.FromDate 	= ДатаНачала;
	WSПараметр.ToDate 		= ДатаОкончания;
	WSПараметр.ValutaCode  	= Валюта.КодЦБ;

	КурсыВалют = ВебСервис.GetCursDynamic(WSПараметр);
		
	Попытка
		Данные = КурсыВалют.GetCursDynamicResult.diffgram;
//		Если Данные.Свойства.Получить("ValuteData") = Неопределено Тогда
//			Возврат;
//		КонецЕсли;
		Данные = Данные.ValuteData.ValuteCursDynamic;
		Если ТипЗнч(Данные) = Тип("СписокXDTO") Тогда
			Для Каждого СтрокаДанных из Данные Цикл
				СформироватьЗаписьКурса(СтрокаДанных, Валюта);
			КонецЦикла;
		ИначеЕсли ТипЗнч(Данные) = Тип("ОбъектXDTO") Тогда
			СформироватьЗаписьКурса(Данные, Валюта);	 
		КонецЕсли;
	Исключение
		Возврат;		
	КонецПопытки;
КонецПроцедуры

Процедура СформироватьЗаписьКурса(СтрокаДанных, Валюта)
	лДатаКурса = Дата(СтрЗаменить(Лев(СтрокаДанных.CursDate, 10), "-" ,""));
		
	МенеджерЗаписи 				= РегистрыСведений.КурсыВалют.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Период 		= лДатаКурса;
	МенеджерЗаписи.Валюта 		= Валюта;
	МенеджерЗаписи.Кратность 	= СтрокаДанных.Vnom;
	МенеджерЗаписи.Курс 		= СтрокаДанных.Vcurs;
	МенеджерЗаписи.Записать();
КонецПроцедуры

Процедура ЗагрузкаКурсовВалютРегламентноеЗадание() Экспорт
	МассивВалют = СформироватьМассивВалютДляЗагрузкиИзИнтернета();
	
	ДатаКурса = НачалоДня(ТекущаяДата());
	Для каждого Валюта из МассивВалют Цикл
		ЗагрузитьКурсВалютыЗаПериод(ДатаКурса, ДатаКурса, Валюта);		
	КонецЦикла;
КонецПроцедуры

Функция СформироватьМассивВалютДляЗагрузкиИзИнтернета() Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Валюты.Ссылка КАК Валюта
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|ГДЕ
	|	Валюты.ЗагружаетсяИзИнтернета";
	
	МассивВалют = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Валюта");
	
	Возврат МассивВалют;
КонецФункции

// Получает код Центрального Банка для передаваемой валюты
// 
// Параметры:
// 	КодВалюты
Функция КодВалютыЦентральногоБанка(КодВалюты) Экспорт
	ВебСервис 		= WSСсылки.КурсВалютЦБ.СоздатьWSПрокси("http://web.cbr.ru/", "DailyInfo", "DailyInfoSoap");
	//@skip-warning
	ТипWSПараметра 	= ВебСервис.ФабрикаXDTO.Пакеты.Получить("http://web.cbr.ru/").Получить("EnumValutes");
	
	WSПараметр	   		= ВебСервис.ФабрикаXDTO.Создать(ТипWSПараметра);
	WSПараметр.Seld 	= ЛОЖЬ;
	
	СправочникВалют = ВебСервис.EnumValutes(WSПараметр);
	
	Попытка
		МассивВалют = СправочникВалют.EnumValutesResult.diffgram.ValuteData.EnumValutes;
		Для каждого Валюта из МассивВалют Цикл
			Если Валюта.Vnom = КодВалюты Тогда
				Возврат Валюта.VcommonCode
			КонецЕсли;
		КонецЦикла;	
		Возврат "";
	Исключение
		Возврат "";
	КонецПопытки;
		
КонецФункции