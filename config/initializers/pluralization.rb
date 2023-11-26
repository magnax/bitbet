# config/initializers/pluralization.rb
module I18n::Backend::Pluralization
  # rules taken from : http://www.gnu.org/software/hello/manual/gettext/Plural-forms.html
  def pluralize(locale, entry, n)
    return entry unless entry.is_a?(Hash) && n

    key = if n.zero? && entry.key?(:zero)
            :zero
          else
            case locale
            when :pl # Polish
              if n == 1
                :one
              else
                n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20) ? :few : :other
              end
            when :cs, :sk # Czech, Slovak
              if n == 1
                :one
              else
                n >= 2 && n <= 4 ? :few : :other
              end
            when :lt # Lithuanian
              if n % 10 == 1 && n % 100 != 11
                :one
              else
                n % 10 >= 2 && (n % 100 < 10 || n % 100 >= 20) ? :few : :other
              end
            when :lv # Latvian
              if n % 10 == 1 && n % 100 != 11
                :one
              else
                n.zero? ? :other : :few
              end
            when :ru, :uk, :sr, :hr # Russian, Ukrainian, Serbian, Croatian
              if n % 10 == 1 && n % 100 != 11
                :one
              else
                n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20) ? :few : :other
              end
            when :sl # Slovenian
              if n % 100 == 1
                :one
              elsif n % 100 == 2
                :few
              else
                n % 100 == 3 || n % 100 == 4 ? :many : :other
              end
            when :ro # Romanian
              if n == 1
                :one
              else
                n.zero? || ((n % 100).positive? && n % 100 < 20) ? :few : :other
              end
            when :gd # Gaeilge
              if n == 1
                :one
              else
                n == 2 ? :two : :other
              end
            # add another language if you like...
            else
              n == 1 ? :one : :other # default :en
            end
          end
    raise InvalidPluralizationData.new(entry, n) unless entry.key?(key)

    entry[key]
  end
end

I18n::Backend::Simple.include I18n::Backend::Pluralization