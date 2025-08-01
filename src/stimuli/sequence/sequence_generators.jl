"""
    generate_random_word_sequence(sequence_length, dictionary, silence_symbol; silent_intervals=1, weights=nothing)

Generate a random word sequence of a given length using a dictionary of words and their corresponding phonemes.

# Arguments
- `sequence_length::Int`: The desired length of the word sequence.
- `dictionary::Dict{Symbol, Vector{Symbol}}`: A dictionary mapping words to their corresponding phonemes.
- `silence_symbol::Symbol`: The symbol representing silence in the word sequence.

# Optional Arguments
- `silent_intervals::Int = 1`: The number of silent intervals between words.
- `weights::Union{Nothing, Vector{Float64}} = nothing`: The weights assigned to each word in the dictionary. If `nothing`, all words have equal weight.

# Returns
- `words::Vector{Symbol}`: The generated word sequence.
- `phonemes::Vector{Symbol}`: The corresponding phonemes for each word in the sequence.
"""
function word_phonemes_sequence(;
    lexicon,
    weights = nothing,
    seed = nothing,
    silent_intervals = 1,
    repetitions::Int,
    kwargs...,
)

    @unpack dict, symbols, silence, ph_duration = lexicon
    if seed !== nothing
        Random.seed!(seed)
    end


    dict_words = collect(keys(dict))
    weights =
        isnothing(weights) ? fill(1, length(dict_words)) :
        [weights[word] for word in dict_words]
    weights = StatsBase.Weights(weights)
    word_frequency = Dict{Symbol,Int}()
    words, phonemes = [], []

    remaining_words = copy(dict_words)
    make_equal = true

    seq_length = round(
        Int,
        length(dict_words) *
        repetitions *
        mean([length(dict[word]) + silent_intervals for word in dict_words]),
    )
    while length(words) < seq_length
        current_word =
            choose_word(make_equal, remaining_words, dict_words, weights, word_frequency)
        word_phonemes = dict[current_word]

        if haskey(word_frequency, current_word)
            word_frequency[current_word] += 1
        else
            word_frequency[current_word] = 1
        end

        if should_fill_with_silence(
            word_phonemes,
            silent_intervals,
            seq_length,
            length(words),
        )
            fill_with_silence!(words, phonemes, silence, seq_length - length(words))
        else
            append_word_and_phonemes!(
                words,
                phonemes,
                current_word,
                word_phonemes,
                silence,
                silent_intervals,
            )
        end
    end
    @assert length(words) == seq_length
    @assert length(phonemes) == seq_length

    return words, phonemes, seq_length
end



"""
    choose_word(make_equal, remaining_words, dict_words, weights, word_frequency)

Choose a word from the given list of words based on the specified criteria.

Arguments:
- `make_equal`: A boolean indicating whether the words should be chosen with equal probability.
- `remaining_words`: A list of words that have not been chosen yet.
- `dict_words`: A list of all available words.
- `weights`: A list of weights corresponding to each word in `dict_words`.
- `word_frequency`: A dictionary mapping words to their frequencies.

Returns:
- A word chosen based on the specified criteria.
"""
function choose_word(make_equal, remaining_words, dict_words, weights, word_frequency)
    if make_equal
        return !isempty(remaining_words) ? pop!(remaining_words) :
               StatsBase.sample(
            dict_words,
            StatsBase.Weights([exp(-word_frequency[word]) for word in dict_words]),
        )
    else
        return StatsBase.sample(dict_words, weights)
    end
end

"""
    should_fill_with_silence(word_phonemes, silent_intervals, sequence_length, current_length)

Check if the remaining sequence should be filled with silence.

Arguments:
- `word_phonemes`: The number of phonemes in the current word.
- `silent_intervals`: The number of silent intervals.
- `sequence_length`: The total length of the sequence.
- `current_length`: The current length of the sequence.

Returns:
- A boolean indicating whether the remaining sequence should be filled with silence.
"""
function should_fill_with_silence(
    word_phonemes,
    silent_intervals,
    sequence_length,
    current_length,
)
    return length(word_phonemes) + silent_intervals > sequence_length - current_length
end

"""
    fill_with_silence!(words, phonemes, silence_symbol, fill_count)

Fill the given lists with silence symbols.

Arguments:
- `words`: A list of words.
- `phonemes`: A list of phonemes.
- `silence_symbol`: The symbol representing silence.
- `fill_count`: The number of times to fill with silence.
"""
function fill_with_silence!(words, phonemes, silence_symbol, fill_count)
    for _ = 1:fill_count
        push!(words, silence_symbol)
        push!(phonemes, silence_symbol)
    end
end

"""
    append_word_and_phonemes!(words, phonemes, word, phonemes_list, silence_symbol, silent_intervals)

Append a word and its corresponding phonemes to the given lists.

Arguments:
- `words`: A list of words.
- `phonemes`: A list of phonemes.
- `word`: The word to append.
- `phonemes_list`: A list of phonemes corresponding to the word.
- `silence_symbol`: The symbol representing silence.
- `silent_intervals`: The number of silent intervals to append after the word.
"""
function append_word_and_phonemes!(
    words,
    phonemes,
    word,
    phonemes_list,
    silence_symbol,
    silent_intervals,
)
    for ph in phonemes_list
        push!(phonemes, ph)
        push!(words, word)
    end

    for _ = 1:silent_intervals
        push!(words, silence_symbol)
        push!(phonemes, silence_symbol)
    end
end

# function silence_sequence!(seq::Encoding)
#     @assert(length(seq.populations) == seq.silence)
#     @assert(seq.populations[seq.silence] == [])
#     fill!(seq.sequence, seq.silence)
# end

# function silence_sequence(seq::Encoding)
#     new_seq = deepcopy(seq)
#     silence_sequence!(new_seq)
#     return new_seq
# end
export word_phonemes_sequence
