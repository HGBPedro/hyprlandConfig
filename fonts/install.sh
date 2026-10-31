#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$PWD"

mkdir -p fonts licenses tmp

for archive in *.dmg; do
    [ -e "$archive" ] || continue

    echo "Processando: $archive..."

    # Extrai o DMG para a pasta tmp local
    7z e "$archive" -y -otmp/ > /dev/null
    cd "$BASE_DIR/tmp"

    # Extrai o pacote .pkg
    7z x -txar *.pkg -y > /dev/null

    # Extrai o nome da fonte para a licença
    _fntname=$(grep -o -e "THE APPLE .* FONT" Resources/English.lproj/License.rtf | head -n 1 || echo "FONT")
    
    # Move a licença sem sobrescrever (-n) caso já exista uma idêntica
    mv -n Resources/English.lproj/License.rtf "$BASE_DIR/licenses/LICENSE.${_fntname// /-}" 2>/dev/null || true

    cd *.pkg/
    _fntver=$(grep -o -e ' version=".*">' PackageInfo | head -n 1 || echo "")
    _fntver="${_fntver:10:-2}"

    # Extrai os conteúdos do Payload
    7z x Payload -y > /dev/null 2>&1 || true
    7z x Payload~ -y > /dev/null 2>&1 || true

    # Copia/Move as fontes de forma incremental sem sobrescrever existentes (-n)
    if [ -d "Library/Fonts" ]; then
        cp -rn Library/Fonts/* "$BASE_DIR/fonts/" 2>/dev/null || true
    fi

    cd "$BASE_DIR"

    # Limpa a pasta temporária para o próximo arquivo DMG
    rm -rf tmp/* tmp/.[!.]* 2>/dev/null || true
    echo "Extraído com sucesso: $archive (Versão: ${_fntver:-desconhecida})"
    echo "----------------------------------------"
done

rmdir tmp 2>/dev/null || true
echo "Concluído! Todas as fontes foram consolidadas na pasta 'fonts/'."
