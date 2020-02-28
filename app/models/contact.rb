class Contact < ActiveRecord::Base
  include Formatador

  only_digits :celular

  has_and_belongs_to_many :groups, class_name: "ContactGroup", dependent: :nullify
  belongs_to :customer

  enum sexo: [:masculino, :feminino]

  validates :nome, :celular, :sexo, presence: true
  validates :celular, length: { minimum: 10, message: "é muito curto para ser um celular" }
  validates :email, format: { with: /(.+)@(.+)\.(.+)/ }, allow_blank: true
  validate :verificar_data_nascimento, date: { before: Date.today, message: 'não pode ser uma data futura' }, allow_blank: true

  SEPARADORES_CSV = {
    virgula: { valor: 0, separador: ","},
    ponto_e_virgula: { valor: 1, separador: ";"},
    tab: { valor: 2, separador: "\t"}
  }

  CAMPOS_INDEX = {
    nome: 0,
    sexo: 1,
    celular: 2,
    email: 3,
    empresa: 4,
    nascimento: 5
  }

  NASCIMENTO_REGEX = %r{([0-9]{2}/){2}[0-9]{4}}

  def celular_formatado
    formatar_telefone self.celular
  end

  def self.gerar_por_string_csv(string_csv, customer, options = {col_sep: SEPARADORES_CSV[:virgula][:separador], encoding: Encoding::UTF_8})
    erros = []

    csv = CSV.parse(string_csv.force_encoding(options[:encoding]).encode(Encoding::UTF_8),
      col_sep: options[:col_sep],
      encoding: Encoding::UTF_8)

    Contact.transaction do
      csv.each_with_index do |linha, i|
        if linha.select(&:present?).present?
          contact = Contact.new         nome: linha[CAMPOS_INDEX[:nome]],
                                        sexo: (linha[CAMPOS_INDEX[:sexo]].try(:upcase) == "F") ? sexos[:feminino] : sexos[:masculino],
                                     celular: linha[CAMPOS_INDEX[:celular]],
                                       email: linha[CAMPOS_INDEX[:email]],
                                     empresa: linha[CAMPOS_INDEX[:empresa]],
                                  nascimento: linha[CAMPOS_INDEX[:nascimento]],
                                 customer_id: customer.id

          erros_da_linha = {}
          erros_da_linha = contact.errors.messages unless contact.save

          unless linha[CAMPOS_INDEX[:sexo]].try(:upcase) == "F" || linha[CAMPOS_INDEX[:sexo]].try(:upcase) == "M"
            erros_da_linha[:sexo] ||= []
            erros_da_linha[:sexo] << "formato inválido"
          end

          unless linha[CAMPOS_INDEX[:nascimento]].blank? || !!(linha[CAMPOS_INDEX[:nascimento]] =~ NASCIMENTO_REGEX)
            erros_da_linha[:nascimento] ||= []
            erros_da_linha[:nascimento] << "formato inválido"
          end

          erros << { (i + 1) => erros_da_linha } if erros_da_linha.any?
        end
      end

      raise if erros.any?
    end

  rescue ArgumentError
    erros = [{ erro_padrao: "Não foi possível ler o arquivo, tente usar outra codificação." }]
  rescue
    if erros.blank? || erros.size == csv.size
      erros = [{ erro_padrao: "Possuem erros no arquivo, verifique se o mesmo possui o formato e separação correta." }]
    end

  ensure
    return erros
  end

  private

    def verificar_data_nascimento
      if self.nascimento.present?
        errors.add(:nascimento, "data inválida") if self.nascimento.to_date > Date.today
      end
    end
end
