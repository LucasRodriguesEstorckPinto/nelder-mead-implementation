using Plots
using LinearAlgebra
using Statistics

# Configura o backend GR explicitamente
gr() # Mais estável para animações

# ===========================
# Funções Objetivo
# ===========================
"""
Função exemplo em R²: (x₁ - 2)⁴ + (x₁ - 2x₂)²
"""
function funcao_r2_exemplo(x::Vector{Float64})
    return (x[1] - 2)^4 + (x[1] - 2 * x[2])^2
end

"""
Função exemplo em R³: x₁² + 2x₂² + 3x₃²
"""
function funcao_r3_exemplo(x::Vector{Float64})
    return x[1]^2 + 2 * x[2]^2 + 3 * x[3]^2
end

# ===========================
# Inicialização do Símplex
# ===========================
"""
Inicializa o símplex com n+1 vértices a partir de um ponto inicial p0 e um passo.
"""
function inicializar_simplex(p0::Vector{Float64}, passo::Float64)
    n = length(p0)
    simplex = Vector{Vector{Float64}}(undef, n + 1)
    simplex[1] = copy(p0)
    for i in 1:n
        pi = copy(p0)
        pi[i] += passo
        simplex[i + 1] = pi
    end
    return simplex
end

# ===========================
# Método de Nelder-Mead
# ===========================
"""
Otimiza uma função f usando o método Simplex de Nelder-Mead.
Retorna o melhor ponto, valor, número de iterações e histórico de símplexes.
"""
function otimizar_nelder_mead(f, p0::Vector{Float64}, passo::Float64; 
                              tolerancia::Float64=1e-6, max_iter::Int=1000, verbose::Bool=true)
    n = length(p0)
    simplex = inicializar_simplex(p0, passo)
    historico = Vector{Vector{Vector{Float64}}}()

    for iteracao in 1:max_iter
        # Avalia a função nos vértices e ordena
        valores = [f(x) for x in simplex]
        ordem = sortperm(valores)
        simplex = simplex[ordem]
        valores = valores[ordem]
        push!(historico, copy(simplex))

        # Verifica convergência
        if valores[end] - valores[1] < tolerancia
            verbose && println("Convergiu após $iteracao iterações")
            return simplex[1], valores[1], iteracao, historico
        end

        # Calcula o centroide dos n melhores pontos
        centroide = mean(simplex[1:end-1])

        # Reflexão
        refletido = centroide + 1.0 * (centroide - simplex[end])
        f_refletido = f(refletido)

        if f_refletido < valores[1]
            # Expansão
            expandido = centroide + 2.0 * (refletido - centroide)
            f_expandido = f(expandido)
            simplex[end] = f_expandido < f_refletido ? expandido : refletido
        elseif f_refletido < valores[end-1]
            # Aceita reflexão
            simplex[end] = refletido
        else
            # Contração
            contraido = centroide + 0.5 * (simplex[end] - centroide)
            f_contraido = f(contraido)
            if f_contraido < valores[end]
                simplex[end] = contraido
            else
                # Redução
                for i in 2:n+1
                    simplex[i] = simplex[1] + 0.5 * (simplex[i] - simplex[1])
                end
            end
        end
    end

    verbose && println("Número máximo de iterações atingido")
    return simplex[1], valores[1], max_iter, historico
end

# ===========================
# Execução Múltipla
# ===========================
"""
Executa múltiplas otimizações com pontos iniciais aleatórios e retorna o melhor ponto e valor.
"""
function executar_multiplas_otimizacoes(f, dim::Int, num_execucoes::Int, min_valor::Float64, 
                                       max_valor::Float64, passo::Float64, tolerancia::Float64, max_iter::Int)
    melhor_valor = Inf
    melhor_ponto = zeros(dim)
    for i in 1:num_execucoes
        p0 = rand(dim) .* (max_valor - min_valor) .+ min_valor
        ponto, valor, iters, _ = otimizar_nelder_mead(f, p0, passo; tolerancia=tolerancia, max_iter=max_iter, verbose=false)
        println("Execução $i: Valor = $(round(valor, digits=2)), Ponto = $ponto, Iterações = $iters")
        if valor < melhor_valor
            melhor_valor = valor
            melhor_ponto = ponto
        end
    end
    return melhor_ponto, melhor_valor
end

# ===========================
# Visualização em R²
# ===========================
"""
Visualiza a evolução dos triângulos em R² sobre as curvas de nível da função.
"""
function visualizar_2d(f)
    println("Iniciando visualização 2D...")
    p0 = [1.0, 1.0]
    passo = 0.1
    _, _, _, historico = otimizar_nelder_mead(f, p0, passo; verbose=false)
    println("Histórico gerado com $(length(historico)) iterações")

    # Gera a grade para curvas de nível (resolução reduzida)
    x = range(-1, 4, length=100) # Reduzido de 400 para 100
    y = range(-1, 4, length=100)
    z = [f([xi, yi]) for xi in x, yi in y]
    println("Grade para curvas de nível gerada")

    # Reduz o número de frames para animação (a cada 2 iterações)
    anim = @animate for k in 1:2:length(historico)
        simplex = historico[k]
        p = contour(x, y, z, levels=20, color=:viridis, title="Iteração $k")
        plot!(p, [simplex[i][1] for i in [1,2,3,1]], [simplex[i][2] for i in [1,2,3,1]], color=:blue, label="Símplex")
        scatter!(p, [simplex[1][1]], [simplex[1][2]], color=:red, label="Melhor ponto")
        println("Frame $k renderizado")
    end
    println("Salvando GIF...")
    gif(anim, "simplex_r2.gif", fps=5) # FPS reduzido para acelerar
    println("Visualização 2D concluída")
end

# ===========================
# Visualização em R³
# ===========================
"""
Visualiza a evolução dos tetraedros em R³.
"""
function visualizar_3d(f)
    println("Iniciando visualização 3D...")
    p0 = [1.0, 1.0, 1.0]
    passo = 0.1
    _, _, _, historico = otimizar_nelder_mead(f, p0, passo; verbose=false)
    println("Histórico gerado com $(length(historico)) iterações")

    anim = @animate for k in 1:2:length(historico) # A cada 2 iterações
        simplex = historico[k]
        p = plot3d(title="Iteração $k", legend=false, xlims=(-1,2), ylims=(-1,2), zlims=(-1,2))
        scatter3d!(p, [x[1] for x in simplex], [x[2] for x in simplex], [x[3] for x in simplex], color=:blue)
        for i in 1:4, j in i+1:4
            plot3d!(p, [simplex[i][1], simplex[j][1]], [simplex[i][2], simplex[j][2]], 
                    [simplex[i][3], simplex[j][3]], color=:gray)
        end
        scatter3d!(p, [simplex[1][1]], [simplex[1][2]], [simplex[1][3]], color=:red, markersize=6)
        println("Frame $k renderizado")
    end
    println("Salvando GIF...")
    gif(anim, "simplex_r3.gif", fps=5)
    println("Visualização 3D concluída")
end

# ===========================
# Execução Principal
# ===========================
function main()
    println("--- Otimização em R² ---")
    melhor_ponto, melhor_valor = executar_multiplas_otimizacoes(
        funcao_r2_exemplo, 2, 5, -2.0, 4.0, 0.1, 1e-6, 1000)
    println("Melhor ponto R²: $melhor_ponto, valor: $(round(melhor_valor, digits=2))\n")

    println("--- Otimização em R³ ---")
    p0 = [1.0, 1.0, 1.0]
    ponto_3d, valor_3d, iteracoes, _ = otimizar_nelder_mead(funcao_r3_exemplo, p0, 0.1)
    println("Melhor ponto R³: $ponto_3d, valor: $(round(valor_3d, digits=2)), iterações: $iteracoes\n")

    println("--- Visualização R² ---")
    visualizar_2d(funcao_r2_exemplo)

    println("--- Visualização R³ ---")
    visualizar_3d(funcao_r3_exemplo)
end

main()