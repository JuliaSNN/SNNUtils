"""
get_projections(type::String, n_tripods::Int64, stim::StimParams)

Connect stimuli to the dendrites and return handles

# Arguments:
type : _symmetric_ or _asymmetric_

n_tripods : number of tripods

stim : stimulus properties
"""
function get_projections(n_tripods::Int64, stim::StimParams)
    projections = Vector{Vector{Int64}}()
    compartments = Vector{Array{Float32,2}}()
    for sym = 1:stim.symbols
        ## For each input cell get a target population of tripods
        target_neurons = rand(1:n_tripods, round(Int, stim.density * n_tripods))
        ## each input cell act asymettrically/simmetrically on each of the target cell
        if stim.input == "asymmetric"
            INPUT = [[0.0f0, stim.strength, 0.0f0], [0.0f0, 0.0f0, stim.strength]]
        elseif stim.input == "symmetric"
            INPUT = [[0.0f0, stim.strength / 2, stim.strength / 2.0, 0.0f0]]
        elseif stim.input == "soma"
            INPUT = [[stim.strength, 0.0f0, 0.0f0]]
        else
            throw("stim.input must be 'symmetric' or 'asymmetric'")
        end
        target_dendrites = hcat(rand(INPUT, length(target_neurons))...)
        ## and to the soma
        push!(projections, target_neurons)
        push!(compartments, target_dendrites)
    end
    return projections, compartments
end

function get_target_dendrites(seq::Encoding)
    populations = Vector{Vector{Vector{Int}}}()
    for (pop, dend) in zip(seq.populations, seq.dendrites)
        s = findall(x -> x > 0, dend[1, :])
        d1 = findall(x -> x > 0, dend[2, :])
        d2 = findall(x -> x > 0, dend[3, :])
        if length(pop) > 0
            push!(populations, [pop[s], pop[d1], pop[d2]])
        end
    end
    return populations
end

function unique_population(index, seq)
    neurons = Set(seq.populations[index])
    for id in eachindex(seq.populations)
        if id != index
            neurons = setdiff(neurons, Set(seq.populations[id]))
        end
    end
    return collect(neurons)
end

# function population(word::String,seq::Encoding, unique=false)
# 	index = findfirst(x->seq.rev_mapping[x]==word,get_words(seq))
# 	if unique
# 		return unique_population(index,seq)
# 	else
#     	return seq.populations[index]
# 	end
# end

function population(index::Int, seq::Encoding, unique = false)
    if unique
        return unique_population(index, seq)
    else
        return collect(Set(seq.populations[index]))
    end
end

function populations(indices::Vector{Int}, seq::Encoding, unique = false)
    return [population(i, seq, unique) for i in indices]
end

function populations(seq::Encoding, unique = false)
    return [population(i, seq, unique) for i in sorted_indices(seq)]
end

function word_populations(seq::Encoding; unique = false)
    return [population(i, seq, unique) for i in eachindex(seq.populations[get_words(seq)])]
end

function only_words_populations(seq)
    ph_phonemes = Set(vcat([seq.populations[i] for i in get_phonemes(seq)]...))
    ph_words = Set(vcat([seq.populations[i] for i in get_words(seq)]...))
    ph_words = setdiff(ph_words, ph_phonemes)
    return vcat(ph_words...)
end

function only_phonemes_populations(seq)
    ph_phonemes = Set(vcat([seq.populations[i] for i in get_phonemes(seq)]...))
    ph_words = Set(vcat([seq.populations[i] for i in get_words(seq)]...))
    ph_phonemes = setdiff(ph_phonemes, ph_words)
    return vcat(ph_phonemes...)
end

function get_pop_neurons(seq::Encoding; n_neurons = 1, rec_mixed = false)
    track_neurons = Vector{Int64}()
    names = Vector{Vector{Any}}()

    for i in eachindex(seq.populations[1:(end-1)])
        neurons = unique_population(i, seq)[1:n_neurons]
        for neuron in neurons
            push!(track_neurons, neuron)
            push!(names, [neuron])
        end
    end
    if rec_mixed
        for (n, pop1) in enumerate(seq.populations)
            for (m, pop2) in enumerate(seq.populations)
                if m > n
                    for _ = 1:n_neurons
                        neuron = collect(intersect(Set(pop1), Set(pop2)))
                        if !isempty(neuron)
                            push!(track_neurons, neuron[1])
                            pop = [n, m]
                            push!(names, pop)
                        else
                            continue
                        end
                    end
                end
            end
        end
    end
    push!(track_neurons, 1) # first sst / pv
    push!(track_neurons, 2) # second sst / pv
    return track_neurons, names
end


## create a random sequence of words with respective phones
function get_word_sequence(
    seq_length::Int,
    dictionary::Dict,
    null_symbol::String;
    silence_duration = 1,
    weights = nothing,
)

    dict_words = Vector{String}(collect(keys(dictionary)))
    if isnothing(weights)
        weights = ones(length(dictionary))
        weights = StatsBase.Weights(weights)
    else
        @assert length(weights) == length(dictionary)
        weights = StatsBase.Weights([weights[k] for k in dict_words])
    end
    word_count = Dict{String,Int}()
    words = []
    phonemes = []
    _seq_length = 0

    initial_words = copy(dict_words)
    # @info initial_words, dict_words
    #@TODO 
    make_equal = true
    while _seq_length < seq_length
        if make_equal
            word =
                !isempty(initial_words) ? pop!(initial_words) :
                StatsBase.sample(
                    dict_words,
                    StatsBase.Weights([exp(-word_count[x]) for x in dict_words]),
                )
        else
            word = StatsBase.sample(dict_words, weights)
        end
        phs = dictionary[word]
        if haskey(word_count, word)
            word_count[word] += 1
        else
            word_count[word] = 1
        end
        if length(phs) + silence_duration > seq_length - _seq_length
            while _seq_length < seq_length
                _seq_length += 1
                push!(words, null_symbol)
                push!(phonemes, null_symbol)
            end
            continue
        end
        for ph in phs
            push!(phonemes, ph)
            push!(words, word)
            _seq_length += 1
        end
        for _ = 1:silence_duration
            push!(words, null_symbol)
            push!(phonemes, null_symbol)
            _seq_length += 1
        end
    end
    # @info word_count
    return words, phonemes
end

function null_sequence!(seq::Encoding)
    @assert(length(seq.populations) == seq.null)
    @assert(seq.populations[seq.null] == [])
    fill!(seq.sequence, seq.null)
end

function null_sequence(seq::Encoding)
    new_seq = deepcopy(seq)
    null_sequence!(new_seq)
    return new_seq
end




function reverse_dictionary(dictionary::Dict)
    reverse = Dict()
    for key in keys(dictionary)
        push!(reverse, dictionary[key] => key)
    end
    return reverse
end
