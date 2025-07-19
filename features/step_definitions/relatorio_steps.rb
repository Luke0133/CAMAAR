require 'uri'

Quando(/^eu clicar em "Download" em um formulário não respondido$/) do
  within('.formularios-list') do
    first('.formulario-card.nao-respondido').click_link('Download')
  end
end

Quando(/^eu clicar em "Download" em um formulário respondido$/) do
  within('.formularios-list') do
    first('.formulario-card:not(.nao-respondido)').click_link('Download')
  end
end

Então(/^um arquivo "\.csv" deve ser baixado$/) do
  iframe = find('iframe', visible: false)
  src = iframe[:src]
  uri = URI(src)
  path = uri.path
  path += "?#{uri.query}" if uri.query

  download_response = page.driver.get(path)
  expect(download_response.headers['Content-Disposition'])
    .to include('attachment')
  expect(download_response.headers['Content-Type'])
    .to eq('text/csv')
end
