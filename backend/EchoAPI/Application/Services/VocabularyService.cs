using AutoMapper;
using EchoAPI.Api.DTOs.Response;
using EchoAPI.Api.DTOs.Requests;
using EchoAPI.Core.Interfaces.Repositories;
using EchoAPI.Core.Entities;

namespace EchoAPI.Application.Services
{
    public class VocabularyService
    {
        private readonly IVocabularyRepository _vocabularyRepository;
        private readonly IMapper _mapper;

        public VocabularyService(IVocabularyRepository vocabularyRepository, IMapper mapper)
        {
            _vocabularyRepository = vocabularyRepository;
            _mapper = mapper;
        }

        public async Task<VocabularyResponse> AddVocabularyAsync(Guid userId, AddVocabularyRequest request)
        {
            var vocabulary = _mapper.Map<Vocabulary>(request);
            vocabulary.UserId = userId;

            await _vocabularyRepository.AddAsync(vocabulary);
            await _vocabularyRepository.SaveChangesAsync();

            return _mapper.Map<VocabularyResponse>(vocabulary);
        }

        public async Task<IEnumerable<VocabularyResponse>> GetUserVocabulariesAsync(Guid userId)
        {
            var vocabularies = await _vocabularyRepository.GetByUserIdAsync(userId);
            return _mapper.Map<IEnumerable<VocabularyResponse>>(vocabularies);
        }

        public async Task<VocabularyResponse?> EditVocabularyAsync(Guid vocabularyId, EditVocabularyRequest request)
        {
            var vocabulary = await _vocabularyRepository.GetByIdAsync(vocabularyId);
            if (vocabulary == null || vocabulary.IsDeleted) throw new InvalidOperationException("Vocabulary not found or unauthorized");

            if (!string.IsNullOrEmpty(request.Expression) || !string.IsNullOrEmpty(request.Translation) || request.ExampleSentence != null)
            {
                vocabulary.Expression = request.Expression;
                vocabulary.Translation = request.Translation;
            }
            
            _vocabularyRepository.Update(vocabulary);
            await _vocabularyRepository.SaveChangesAsync();

            return _mapper.Map<VocabularyResponse>(vocabulary);
        }

        public async Task<bool> DeleteVocabularyAsync(Guid vocabularyId)
        {
            var vocabulary = await _vocabularyRepository.GetByIdAsync(vocabularyId);
            if (vocabulary == null || vocabulary.IsDeleted) 
                throw new InvalidOperationException("Vocabulary not found or unauthorized");
            
            vocabulary.IsDeleted = true;
            _vocabularyRepository.Update(vocabulary);
            await _vocabularyRepository.SaveChangesAsync();

            return true;
        }
    }
}
