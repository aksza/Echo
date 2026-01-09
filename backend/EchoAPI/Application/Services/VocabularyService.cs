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
    }
}
