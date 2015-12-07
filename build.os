﻿#Использовать logos

Перем Лог;

Процедура ВыполнитьКоманду(Знач КомандаЗапуска, Знач ТекстОшибки = "", Знач РабочийКаталог = "")

	Лог.Информация("Выполняю команду: " + КомандаЗапуска);

	Если НЕ ЗначениеЗаполнено(РабочийКаталог) Тогда
		РабочийКаталог = ТекущийКаталог();
	КонецЕсли;

	//Процесс = СоздатьПроцесс(КомандаЗапуска, ТекущийКаталог(), Истина, , КодировкаТекста.UTF8);
	//Процесс.Запустить();

	//Процесс.ОжидатьЗавершения();

	//Пока НЕ Процесс.Завершен Цикл
	//	Пока Процесс.ПотокВывода.ЕстьДанные Цикл
	//		СтрокаВывода = Процесс.ПотокВывода.ПрочитатьСтроку();
	//		Сообщить(СтрокаВывода);
	//	КонецЦикла;
	//КонецЦикла;

	//Если Процесс.КодВозврата <> 0 Тогда
	//	Лог.Ошибка("Код возврата: " + Процесс.КодВозврата);
	//	ВызватьИсключение ТекстОшибки;
	//КонецЕсли;

	КодВозврата = 0;
	ЗапуститьПриложение(КомандаЗапуска, РабочийКаталог, Истина, КодВозврата);

	Если КодВозврата <> 0 Тогда
		Лог.Ошибка("Код возврата: " + КодВозврата);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

КонецПроцедуры

Процедура ОбновитьПакетРедактора(ДанныеКоманды)

	ВыполнитьКоманду("git pull", , ДанныеКоманды.ПапкаРепозитория);

	ФайлИсточник = Новый Файл(ДанныеКоманды.ПутьКФайлуИсточнику);

	ПутьКФайлуПриемнику = ДанныеКоманды.ПапкаРепозитория;
	Если ЗначениеЗаполнено(ДанныеКоманды.ПоместитьВПапку) Тогда
		ПутьКФайлуПриемнику = ОбъединитьПути(ПутьКФайлуПриемнику, ДанныеКоманды.ПоместитьВПапку);
	КонецЕсли;
	ПутьКФайлуПриемнику = ОбъединитьПути(ПутьКФайлуПриемнику, ФайлИсточник.Имя);

	КопироватьФайл(ДанныеКоманды.ПутьКФайлуИсточнику, ПутьКФайлуПриемнику);

	ВыполнитьКоманду("git add .", , ДанныеКоманды.ПапкаРепозитория);

	ВыполнитьКоманду("git commit -m ""Grammars update""", , ДанныеКоманды.ПапкаРепозитория);

КонецПроцедуры

Функция Конструктор_ДанныеКомандыОбновленияПакета()

	ДанныеКоманды = Новый Структура;

	ДанныеКоманды.Вставить("ПутьКФайлуИсточнику", 	"");
	ДанныеКоманды.Вставить("ПапкаРепозитория", 		"");
	ДанныеКоманды.Вставить("ПоместитьВПапку", 		"");

	Возврат ДанныеКоманды;

КонецФункции

Лог = Логирование.ПолучитьЛог("oscript.app.1c-syntax");
Лог.УстановитьУровень(УровниЛога.Информация);

КаталогСборки = ТекущийКаталог();

ПутьКБинарникамНод = ОбъединитьПути("node_modules", ".bin");
ПутьКБинарникамНод = ПутьКБинарникамНод + ПолучитьРазделительПути();

КомандаЗапуска = "npm -v";
ВыполнитьКоманду(КомандаЗапуска, "Ошибка проверки версии npm");

КомандаЗапуска = "npm install";
ВыполнитьКоманду(КомандаЗапуска, "Ошибка установки пакетов node.js");

КомандаЗапуска = ПутьКБинарникамНод + "yaml2json --pretty 1c.YAML-tmLanguage > 1c.json";
ВыполнитьКоманду(КомандаЗапуска, "Ошибка компиляции YAML -> JSON");

КомандаЗапуска = ПутьКБинарникамНод + "json2cson 1c.json > 1c.cson";
ВыполнитьКоманду(КомандаЗапуска, "Ошибка компиляции JSON -> CSON");

ИмяВременногоФайла = ОбъединитьПути(ТекущийКаталог(), "build_tmLanguage.js");

ТекстовыйДокумент = Новый ТекстовыйДокумент;

ТекстСкрипта =
"var plist = require('plist');
|var fs = require('fs');
|
|var jsonString = fs.readFileSync('1c.json', 'utf8');
|var jsonObject = JSON.parse(jsonString);
|var plistString = plist.build(jsonObject);
|
|fs.writeFileSync('1c.tmLanguage', plistString);";

ТекстовыйДокумент.УстановитьТекст(ТекстСкрипта);
ТекстовыйДокумент.Записать(ИмяВременногоФайла);

КомандаЗапуска = "node " + ИмяВременногоФайла;
ВыполнитьКоманду(КомандаЗапуска, "Ошибка компиляции JSON -> tmLanguage");

УдалитьФайлы(ИмяВременногоФайла);

ПапкаРепозиториев = ОбъединитьПути(ТекущийКаталог(), "..");
ИмяПакета = "language-1c-bsl";

ИмяПапки_Sublime 	= "sublime-" + ИмяПакета;
ИмяПапки_VSC 		= "vsc-" + ИмяПакета;
ИмяПапки_Atom 		= "atom-" + ИмяПакета;

Папка_Sublime 	= ОбъединитьПути(ПапкаРепозиториев, ИмяПапки_Sublime);
Папка_VSC 		= ОбъединитьПути(ПапкаРепозиториев, ИмяПапки_VSC);
Папка_Atom 		= ОбъединитьПути(ПапкаРепозиториев, ИмяПапки_Atom);

ДанныеКоманды_Sublime = Конструктор_ДанныеКомандыОбновленияПакета();
ДанныеКоманды_Sublime.ПутьКФайлуИсточнику = ОбъединитьПути(КаталогСборки, "1c.tmLanguage");
ДанныеКоманды_Sublime.ПапкаРепозитория = Папка_Sublime;

ОбновитьПакетРедактора(ДанныеКоманды_Sublime);

ДанныеКоманды_VSC = Конструктор_ДанныеКомандыОбновленияПакета();
ДанныеКоманды_VSC.ПутьКФайлуИсточнику = ОбъединитьПути(КаталогСборки, "1c.tmLanguage");
ДанныеКоманды_VSC.ПапкаРепозитория = Папка_VSC;

ОбновитьПакетРедактора(ДанныеКоманды_VSC);

ДанныеКоманды_Atom = Конструктор_ДанныеКомандыОбновленияПакета();
ДанныеКоманды_Atom.ПутьКФайлуИсточнику = ОбъединитьПути(КаталогСборки, "1c.cson");
ДанныеКоманды_Atom.ПапкаРепозитория = Папка_Atom;
ДанныеКоманды_Atom.ПоместитьВПапку = "grammars";

ОбновитьПакетРедактора(ДанныеКоманды_Atom);