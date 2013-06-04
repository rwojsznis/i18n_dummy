## i18n Dummy

Slow, clumsy pseudo yaml parser for your Rails locales. More description coming soon (hopefully).

**This is still work in progress**, be careful and use a long stick!

### What it is all about and how to use it?

1. Clone the repository to your local machine and install required gems (`.ruby-version` file included)

2. Create `config.yml` file in root directory. Included example below:

``` yaml
application:
  base: 'locales/base.en.yml'
  polish: 'locales/base.pl.yml'
  spanish: 'locales/base.se.yml'
  french: 'locales/base.fr.yml'
tour:
  base: 'locales/tour.en.yml'
  polish: 'locales/tour.pl.yml'
  spanish: 'locales/tour.se.yml'
  french: 'locales/tour.fr.yml'
```

Application assumes that you have one or more locales and each one have 'base' locale (English in example above) that will be used to sync other locales. You can provide relative or absolute paths for your files.

Note: `base` key is required, you can name other keys to your liking.

3. Run application from your command line (`ruby run.rb`). It should be available on `http://localhost:4567`

### What is translated and what is not?

Application doesn't use any external storage, you don't hook it up to your existing rails project or anything. It runs on Sinatra using Thin server. So how it knows what needs to be translated? There is a strong assumption how to distinguish it - it uses comments. When a translation string have a `FIX ME` (or `FIXME`) comment it's marked as not translated. So when you add new key to your base locale it will be copied to other locales with that marker.

There is also a way of updating keys in base locale. When you modify base translation and you want to overwrite that key in other locale you add an capital `U` (this is configurable - you may use custom prefix or suffix) at the end of the key name (in a base locale). I'm not sure it this makes any sense to you, so I will provide an example:

Current base:
``` yaml
en:
  helloU: "Hello"
  bye: "Bye"
  new_key: "I'm a new key!"
```

Spanish
``` yaml
es:
   hello: "Hola"
   bye: "Adiós"
   some_key: "This doesn't exists in base locale so it will be removed"
```

And the result will be:

``` yaml
en:
  hello: "Hello"
  bye: "Bye"
  new_key: "I'm a new key!"
```

``` yaml
es:
   hello: "Hello" # FIX ME
   bye: "Adiós"
   new_key: "I'm a new key!" # FIX ME
```

As you see the `U` marker was removed and Spanish locale was synced basing on base locale. I hope that makes more sense now :).

### Configuration

At this point you can configure custom suffix / prefix that will be used for detecting updated keys in base locale. See the `settings.yml.example`.

### Limitations and other assumptions

* first of all this project is in very early stage, it was basically written in one weekend so don't expect to much ;) - it's not heavily tested, there is a huge probability that it might blow up in your face at this stage

* indentation = __2 spaces__ (indentation detection not yet implemented) it also won't handle some random comments/blank lines (yet)

* not all of YAML features are supported (e.g. no references and multi-line entries starting from `>`)

* each of your translation string will end up in double quotes (this is not configurable at the moment and you may not like it)

* base locale is sacred - if you add something to your other locale it will be removed (it will be shown in current file preview)

* browser links are valid for SublimeText only (this is also not yet configurable)


I hope I will find some spare time to keep this project alive :).
