          BRANCH_NAME=${GITHUB_REF#refs/heads/}
          BASE_BRANCH="dev"
          
          # Obtener el mensaje del último commit
          COMMIT_MESSAGE="${{ github.event.head_commit.message }}"
          echo "Commit message: $COMMIT_MESSAGE"
          
          # Limpiar el mensaje del commit (remover saltos de línea para el título)
          PR_TITLE=$(echo "$COMMIT_MESSAGE" | head -n1 | sed 's/^\[[^]]*\]//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
          echo "PR Title: $PR_TITLE"
          
          # # Si el título está vacío, usar un título por defecto
          # if [ -z "$PR_TITLE" ]; then
          #   PR_TITLE="Draft: $BRANCH_NAME"
          # else
          #   PR_TITLE="Draft: $PR_TITLE"
          # fi
          
          # Crear el cuerpo del PR con el mensaje completo del commit
          PR_BODY="**PR creado automáticamente**\n\n- Creado por: @$GITHUB_ACTOR\n- Rama: $BRANCH_NAME\n- Commit: ${{ github.event.head_commit.id }}\n- Estado: BORRADOR\n\n**Mensaje del commit:**\n\`\`\`\n$COMMIT_MESSAGE\n\`\`\`\n\n**Instrucciones:**\n1. Cambia la label a \"LISTO PARA VERIFICAR\" cuando esté listo\n2. Los revisores serán notificados automáticamente"
           
          echo "Creando PR con título: $PR_TITLE"
          echo "Rama origen: $BRANCH_NAME"
          echo "Rama destino: $BASE_BRANCH"

          # Crear PR en estado draft
          PR_NUMBER=$(curl -s -L -X POST \
            -H "Authorization: Bearer $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Content-Type: application/json" \
            "https://api.github.com/repos/${{ github.repository }}/pulls" \
            -d @- <<EOF
          {
            "title": "$PR_TITLE",
            "head": "$BRANCH_NAME",
            "base": "$BASE_BRANCH",
            "body": "$PR_BODY",
            "draft": true
          }
          EOF
          )
          echo "$PR_NUMBER" | jq -r '.number' > pr_number.txt
          echo "pr_number=$(cat pr_number.txt)" >> $GITHUB_OUTPUT
        
          
          if [ "$PR_NUMBER" != "null" ]; then
            echo "pr_no=false" >> GITHUB_OUTPUT
            echo "no se creo ni madres"
            exit 0
          else  
            echo "PR=true" >> $GITHUB_OUTPUT
            echo "sisecreo<<EOF" >> GITHUB_OUTPUT
            echo "PR creado exitosamente: #$PR_NUMBER" >> GITHUB_OUTPUT
          fi